% this is a modified implementation of REM.1 from the Shiffrin and Steyvers (1997) paper
% we make many references to it - additionally, we add in a WM module
classdef REMplusWM
	properties
		
		%%%%%%%%%%%%%%%%%%%%
		% STATE variables
		%%%%%%%%%%%%%%%%%%%%

		% this corresponds to the items to be presented
		items = [];

		% EM store of traces
		EMStore = [];
		% this tells us for each value in EMStore, which item number it was generated from
		EMStoreItemIdcs = [];

		% WM store - currently only contains a single memory trace at a time
		WMStore = [];
		% this tells us for the value in WMStore, which item number it was generated from
		WMStoreItemIdcs = [];
		lastWMRehearsalTime = [];

		currentTrial = 0;
		currentContext = [];
		currentTarget = [];
		currentTimeInTrial = 0;

		currentRNGSeed = 102387;

		%%%%%%%%%%%%%%%%%%%%
		% SETTINGS variables
		%%%%%%%%%%%%%%%%%%%%
		
		% standard REM stuff from Shiffrin and Steyvers paper (1997)
		% this is how many items we have in each list
		numUniqueItems = 10;
		% this is w in the Shiffrin paper
		numItemFeatures = 20;
		% this is t in the Shiffrin paper
		numStorageAttempts = 10;
 		% this is g in the paper a.k.a environmental base rate for a feature
		geometricDistP  = 0.4; % remember this has support from 1 .. infinity

 		% this is referred to as u^* in the Shiffrin paper; 
		% it basically tells us, at each timestep, what our probability is of encoding a particular feature (not necessarily the CORRECT feature)
		probFeatureEncoded = 0.04;

		% this is c in the Shiffrin paper;
		% it tells us what the probability of encoding the CORRECT feature value
		% is, IF we're going to store anything at all for this feature
		probCorrectFeatureEncoded = 0.7;

		% Context settings - some things here have no equivalent in the REM model/paper
		% this is 
		numContextFeatures = 20;
		% this indicates whether or not we should gradually 
		uniformContextThroughoutTrial = true;
		% context geometric
		contextGeometricDistP = 0.5;
		% this tells us whether we create a new context vector from scratch on each trial
		% or if we take the current context vector and randomly resample some features from it as
		% a way of gradually shifting
		shiftContextAcrossTrials = true;
		% probability with which we resample a feature, currently chosen so that with 20 context features, we can expect to
		% resample around four features around each time
		probContextFeatureResample = 0.2;

		% Other settings
		% this tells us whether we replace or simply append memory traces for EM
		replaceMemoryTraceForItems = false;

		% Settings used for WM
		% this tells us the time between presentations in a single trial - the units are arbitrary and really only matter
		% with respect to its relationship to the WM rehearsal frequency and decay values
		timeBetweenPresentations = 5;
		% WM rehearsal frequency
		rehearsalFreqWM = 20;
		% feature decay probability: this specifies the probability that a feature gets resampled at each time unit
		probFeatureDecayWMTrace = 0.05;
		probFeatureEncodedWM = 0.4;

	end
	methods
		% constructor currently has nothing to do
		function this = REMplusWM(numUniqueItems, currentRNGSeed)
            this.numUniqueItems = numUniqueItems;
            this.currentRNGSeed = currentRNGSeed;
			this = createListItems(this);
		end

		function this = setupNewTrial(this,target_item_idx)
			this.currentTrial = this.currentTrial + 1;

			this.currentTimeInTrial = 0;

			% select context for this trial
			this = this.makeAndSetNewContext();

			% set which item is our target for this trial;
			% select randomly if target_item_idx not specified
			if nargin < 2
				[this,target_item_idx] = this.setRandomTargetItem();
			else
				[this] = this.setTargetItem(target_item_idx);
			end

			% encode the current item with the current context into EM
			this = encodeEM(this,target_item_idx);

			% encode the current item with the current context into WM
			this = encodeWM(this,target_item_idx);

		end

		function this = createListItems(this)
			this.items = geornd(this.geometricDistP ,this.numItemFeatures, this.numUniqueItems) + 1;
		end

		% will select a target idx and set it as a target for this trial
		function [this, target_idx] = setRandomTargetItem(this)
			target_idx = randi(this.numUniqueItems);
			this.currentTarget = target_idx;
		end

		% allows us to specify a target if we so please
		function [this] = setTargetItem(this,item_idx)
			this.currentTarget = item_idx;
		end
		
		% this is used for creating a new context for a trial. new can mean:
		% 1) brand new context generated according to geometric distribution
		% 2) shifting the context from the last trial to produce a new context
		function [this] = makeAndSetNewContext(this)
			if this.shiftContextAcrossTrials && this.currentTrial ~= 1
				% we want to shift our current context instead of generate a new one from scratch
				this.currentContext = this.shiftCurrentContext();
			else
				this.currentContext = geornd( this.contextGeometricDistP, this.numContextFeatures,1) + 1;
			end
		end

		% returns a shifted context vector - the shift occurs as a probability of resampling features in the current context vector
		function [shifted_context_vector] = shiftCurrentContext(this)
			shifted_context_vector = this.currentContext;
			for feature_idx = 1 : this.numContextFeatures
				if rand < this.probContextFeatureResample
					shifted_context_vector(feature_idx) = geornd(this.contextGeometricDistP, 1,1) + 1;
				end
			end
		end

		% just a helper fn that allows you to specify an item index instead of the item itself
		% NOTE: this appends the current context
		function [odds_ratio, p_old_given_data, p_new_given_data] = getOddsRatioForItemIdx(this,item_idx)
			% our full vector to encode is the concatenated item + currentContext
			item = [this.items(:,item_idx); this.currentContext];

			[odds_ratio, p_old_given_data, p_new_given_data] = this.getOddsRatioForItem(item);
		end

		% the odds ratio for an item is defined as phi in the Shiffrin paper
		function [odds_ratio, p_old_given_data, p_new_given_data, item_trace_likelihood_ratios] = getOddsRatioForItem(this, item)
		% NOTE: it is assumed that item parameter has the appropriate context features
		% appended to it
			num_traces = size(this.EMStore,2);

			% these store the per  trace likelihood ratios;
			% these are lambda in the Shiffrin paper
			item_trace_likelihood_ratios = zeros(1,num_traces);
			p_old_given_data = zeros(1,num_traces);
			p_new_given_data = zeros(1,num_traces);

			% iterate through each memory trace in EMStore
			for trace_idx = 1 : num_traces
				EM_trace = this.EMStore(:,trace_idx);

				[item_trace_likelihood_ratios(trace_idx), p_old_given_data(trace_idx), p_new_given_data(trace_idx)] = this.calculateItemTraceOddsRatio(EM_trace,item);
            end
            
            odds_ratio = mean(item_trace_likelihood_ratios);
			p_old_given_data = mean(p_old_given_data);
			p_new_given_data = mean(p_new_given_data);
		end

		function [item_trace_likelihood, p_old_given_data, p_new_given_data] = calculateItemTraceOddsRatio(this, EM_trace, item)
			% it's easier to do this if we split it into item features and context feaures
			EM_trace_context_features = EM_trace(this.numItemFeatures+1:end);
			EM_trace_item_features = EM_trace(1:this.numItemFeatures);
			% do the same for the item
			item_context_features = item(this.numItemFeatures+1:end);
			item_item_features = item(1:this.numItemFeatures);

			% now remove zero entries from both the memory trace and the actual item
			% item features
			nonzero_item_idcs = find(EM_trace_item_features ~= 0);
			item_item_features = item_item_features(nonzero_item_idcs);
			EM_trace_item_features = EM_trace_item_features(nonzero_item_idcs);
			% context features
			nonzero_item_idcs = find(EM_trace_context_features ~= 0);
			item_context_features = item_context_features(nonzero_item_idcs);
			EM_trace_context_features = EM_trace_context_features(nonzero_item_idcs);

			% okay, so now we have 2 pairs of vectors we need to match to each other. one pair corresponds to item features, the other to context features
			[item_trace_likelihood, p_old_given_data, p_new_given_data] = REM.itemTraceOddsRatioHelper(EM_trace_item_features,item_item_features,this.probCorrectFeatureEncoded,this.geometricDistP);
			[item_trace_likelihood_context, p_old_given_data_context, p_new_given_data_context] = REM.itemTraceOddsRatioHelper(EM_trace_context_features,item_context_features,this.probCorrectFeatureEncoded,this.contextGeometricDistP);

			% here we actually combine the results
			item_trace_likelihood = item_trace_likelihood * item_trace_likelihood_context;
			p_old_given_data = p_old_given_data * p_old_given_data_context;
			p_new_given_data = p_new_given_data * p_new_given_data_context;

		end
		

		% currently, this just gets a clean copy of the item and context - we can add noisy encoding later if we so please
		function this = encodeWM(this, item_idx)

			% our full vector to encode is the concatenated item + currentContext
			item = [this.items(:,item_idx); this.currentContext];

			first_context_feature_idx = size(this.items,1) + 1;

			encoded_trace = zeros(size(item));

			% iterate through each feature
			for feature_idx = 1 : numel(item)
				
				feature_encoded = false;
				for time_unit = 1 : this.numStorageAttempts

					% decide if we'll encode this feature
					if rand < this.probFeatureEncodedWM
						feature_encoded = true;

						% if we decide to encode this feature, decide if we grab the correct value or a random value for this feature
						if rand < this.probCorrectFeatureEncoded
							encoded_trace(feature_idx) = item(feature_idx);
						else % we failed to encode the correct feature, generate random value according to either item feature dist or context feature dist.
							if feature_idx < first_context_feature_idx
								encoded_trace(feature_idx) = geornd(this.geometricDistP,1,1) + 1;
							else % we're dealing with a context feature, let's randomly draw from a geometric dist with the context feature value
								encoded_trace(feature_idx) = geornd(this.contextGeometricDistP,1,1) + 1;
							end
						end
					end
					
					if feature_encoded
						break;
					end

				end
			end


			% just add them in
			this.WMStore = encoded_trace;
			this.WMStoreItemIdcs = item_idx;

			this.lastWMRehearsalTime = this.currentTimeInTrial;
		end

		function [this] = updateTrialTime(this)
			this.currentTimeInTrial = this.currentTimeInTrial + this.timeBetweenPresentations;
		end

		function [this, numDecayedFeatures] = decayWMtrace(this)
			numElapsedTimeUnits = this.currentTimeInTrial - this.lastWMRehearsalTime;
			decayedWMtrace = this.WMStore;
			numDecayedFeatures = 0;
		
			for t = 1 : numElapsedTimeUnits
				% decide if we'll flip off a feature
				if rand() < this.probFeatureDecayWMTrace
					numDecayedFeatures = numDecayedFeatures + 1;

					% randomly select a feature to modify - making sure we only use features that haven't already been turned off
					feature_idx_to_turn_off = randi(numel(decayedWMtrace));

					% second part makes sure we don't get stuck in an infinite loop
					while (decayedWMtrace(feature_idx_to_turn_off) == 0 && sum(decayedWMtrace) ~= 0 )
						feature_idx_to_turn_off = randi(numel(decayedWMtrace));
					end

					decayedWMtrace(feature_idx_to_turn_off) = 0;
				end
			end

			this.WMStore = decayedWMtrace;
		end

		function [this, performedRehearsal, didRetrievalReturnDifItem] = updateWMifNeeded(this)
			didRetrievalReturnDifItem = false;
			performedRehearsal = false;

			% check if we've exceeded our rehearsal thresh
			if (this.currentTimeInTrial - this.lastWMRehearsalTime) >= this.rehearsalFreqWM

				performedRehearsal = true; this.lastWMRehearsalTime = this.currentTimeInTrial;

				% cue EM using WM trace
				[odds_ratio, ~, ~, odds_ratio_all_EM_traces] = this.getOddsRatioForItem(this.WMStore);
				% now we find the one with the highest match value and stick that trace into WM
				[max_match max_match_idx] = max(odds_ratio_all_EM_traces);

				% actually swap out the contents
				this.WMStore = this.EMStore(:,max_match_idx);
				oldItemIdx = this.WMStoreItemIdcs;
				this.WMStoreItemIdcs = this.EMStoreItemIdcs(max_match_idx);


				% just so we can keep track of the success of WM retrievals
				if this.WMStoreItemIdcs ~= oldItemIdx
					didRetrievalReturnDifItem = true;
				end

			end
		end

		function this = encodeEM(this, item_idx)
			% our full vector to encode is the concatenated item + currentContext
			item = [this.items(:,item_idx); this.currentContext];

			first_context_feature_idx = size(this.items,1) + 1;

			encoded_trace = zeros(size(item));

			% iterate through each feature
			for feature_idx = 1 : numel(item)
				
				feature_encoded = false;
				for time_unit = 1 : this.numStorageAttempts

					% decide if we'll encode this feature
					if rand < this.probFeatureEncoded
						feature_encoded = true;

						% if we decide to encode this feature, decide if we grab the correct value or a random value for this feature
						if rand < this.probCorrectFeatureEncoded
							encoded_trace(feature_idx) = item(feature_idx);
						else % we failed to encode the correct feature, generate random value according to either item feature dist or context feature dist.
							if feature_idx < first_context_feature_idx
								encoded_trace(feature_idx) = geornd(this.geometricDistP,1,1) + 1;
							else % we're dealing with a context feature, let's randomly draw from a geometric dist with the context feature value
								encoded_trace(feature_idx) = geornd(this.contextGeometricDistP,1,1) + 1;
							end
						end
					end
					
					if feature_encoded
						break;
					end

				end
			end

			% finally insert into existing EM items
			this = this.addEncodedItemToEMStore(item_idx, encoded_trace);

		end

		function [WM_match_value]  = probeWM(this,item_idx)
			% our full vector to encode is the concatenated item + currentContext
			target_item = this.items(:,item_idx);

			% we compare them separately because they were generated with different geometric base rates
			WMtraceItemFeaturesOnly = this.WMStore(1:this.numItemFeatures);
			WMtraceContextFeaturesOnly = this.WMStore(this.numItemFeatures+1:end);

			% finally calculate the match strength
			WM_match_value = REMplusWM.itemTraceOddsRatioHelper(WMtraceItemFeaturesOnly, target_item, this.probCorrectFeatureEncoded, this.geometricDistP) ...
									* REMplusWM.itemTraceOddsRatioHelper(WMtraceContextFeaturesOnly, this.currentContext,  this.probCorrectFeatureEncoded, this.contextGeometricDistP);
		end

		function this = addEncodedItemToEMStore(this,encoded_item_idx, encoded_trace)
			% encoded_item_idx corresponds to which item number the encoded trace belongs to i.e. we selected item 5 as our target
			% underwent the noisy encoding process to generate encoded_trace, and therefore encoded_item_idx is equal to 5

			if this.replaceMemoryTraceForItems
				EM_store_location_for_item = find(this.EMStoreItemIdcs == encoded_item_idx);
				if isempty(EM_store_location_for_item)
					% memory trace's item has not been stored, let's just append it to the end
					this.EMStore = [this.EMStore encoded_trace];
					this.EMStoreItemIdcs = [this.EMStoreItemIdcs encoded_item_idx];
				else
					% memory trace's item has been stored, let's replace it with the memory trace for this item from this trial
					this.EMStore(:,EM_store_location_for_item) = encoded_trace;
				end
			else % this is the logic where we DON'T REPLACE memory traces
				% let's just append it to the end
				this.EMStore = [this.EMStore encoded_trace];
				this.EMStoreItemIdcs = [this.EMStoreItemIdcs encoded_item_idx];
			end
		end


	end

	methods(Static = true)
		function [odds_ratio, p_old_given_data, p_new_given_data] = itemTraceOddsRatioHelper(trace, item, c, geometric_dist_p)
			match_idcs = find(trace == item);
			num_matches = numel(match_idcs);
			odds_ratio = 1;
			p_old_given_data = 1.0;
			p_new_given_data = 1.0;
			for match_idx = 1 : num_matches
				feature_value = trace(match_idcs(match_idx));

				% in the Shiffrin paper, this is the product on the right half of the right hand side of equation A7 
				p_old_given_data = p_old_given_data * (c + (1-c)*geometric_dist_p*(1-geometric_dist_p)^(feature_value-1));
				p_new_given_data = p_new_given_data * (geometric_dist_p*(1-geometric_dist_p)^(feature_value-1)) ;
			end
			num_mismatches = numel(trace) - num_matches;
			% in the Shiffrin paper, this comes out to the left half of the right side of equation A7 in the appendix
			p_old_given_data = p_old_given_data * (1 - c) ^ num_mismatches;
			odds_ratio = p_old_given_data / p_new_given_data;

        end

        % this will test our code against the numerical example in Shiffrin
        % paper. this only insures that our odds_ratio function is correct,
        % it cannot verify anything about the encoding (since that's
        % probabilistic) or context features (not included in numerical
        % example)
		function [distractor, target] = unit_test_odds_ratio_against_Shiffrin_example()
			test = REM;
			% set values as specified in Shiffrin paper numerical example
			test.numItemFeatures = 4;
			test.numContextFeatures = 0;
			test.geometricDistP = 0.4;
			test.items = [6 3; 1 2; 1 1; 3 1];
			% here we hard code how the items were encoded
			test.EMStore = [0 2; 1 2; 0 1; 3 0];

			% now we test the distractor case
			distractor = test.getOddsRatioForItem([2 3 4 3]');

            % now we test an actual target
			target = test.getOddsRatioForItem([6 1 1 3]');
            
            CORRECT_DISTRACTOR_VALUE = 0.92;
            CORRECT_TARGET_VALUE = 5.38;
            
            assert( abs(distractor - CORRECT_DISTRACTOR_VALUE) < 0.1);
            assert( abs(target - CORRECT_TARGET_VALUE) < 0.1);
            
		end
	end

end



