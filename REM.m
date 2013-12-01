% this is a modified implementation of REM.1 from the Shiffrin and Steyvers (1997) paper
% we make many references to it
classdef REM
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

		currentTrial = 0;
		currentContext = [];
		currentTarget = [];

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
		contextGeometricDistP = 0.9;
		% this tells us whether we create a new context vector from scratch on each trial
		% or if we take the current context vector and randomly resample some features from it as
		% a way of gradually shifting
		shiftContextAcrossTrials = true;
		% probability with which we resample a feature, currently chosen so that with 20 context features, we can expect to
		% resample around two features each time
		probContextFeatureResample = 0.1;

		% Other settings
		% this tells us whether we replace or simply append memory traces
		replaceMemoryTraceForItems = false;
	end
	methods
		% constructor currently has nothing to do
		function this = REM(numUniqueItems, currentRNGSeed)
            this.numUniqueItems = numUniqueItems;
            this.currentRNGSeed = currentRNGSeed;
			this = createListItems(this);
		end

		function this = setupNewTrial(this,target_item_idx)
			this.currentTrial = this.currentTrial + 1;

			% select context for this trial
			this = this.makeAndSetNewContext();

			% set which item is our target for this trial;
			% select randomly if target_item_idx not specified
			if nargin < 2
				[this,target_item_idx] = this.setRandomTargetItem();
			else
				[this] = this.setTargetItem(target_item_idx);
			end

			% encode the current item with the current context
			this = encode(this,target_item_idx);

		end

		function this = createListItems(this)
			this.items = geornd(this.geometricDistP ,this.numItemFeatures, this.numUniqueItems);
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
				this.currentContext = geornd( this.contextGeometricDistP, this.numContextFeatures,1);
			end
		end

		% returns a shifted context vector - the shift occurs as a probability of resampling features in the current context vector
		function [shifted_context_vector] = shiftCurrentContext(this)
			shifted_context_vector = this.currentContext;
			for feature_idx = 1 : this.numContextFeatures
				if rand < this.probContextFeatureResample
					shifted_context_vector(feature_idx) = geornd(this.contextGeometricDistP, 1,1);
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
		function [odds_ratio, p_old_given_data, p_new_given_data] = getOddsRatioForItem(this, item)
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
		
		function this = encode(this, item_idx)
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
								encoded_trace(feature_idx) = geornd(this.geometricDistP,1,1);
							else % we're dealing with a context feature, let's randomly draw from a geometric dist with the context feature value
								encoded_trace(feature_idx) = geornd(this.contextGeometricDistP,1,1);
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
			else % this is the logic where we don't ever REPLACE memory traces
				% let's just append it to the end
				this.EMStore = [this.EMStore encoded_trace];
				this.EMStoreItemIdcs = [this.EMStoreItemIdcs encoded_item_idx];
			end
		end


	end

	methods(Static = true)
		function [odds_ratio, p_old_given_data, p_new_given_data] = itemTraceOddsRatioHelper(EM_trace, item, c, geometric_dist_p)
			match_idcs = find(EM_trace == item);
			num_matches = numel(match_idcs);
			odds_ratio = 1;
			p_old_given_data = 1.0;
			p_new_given_data = 1.0;
			for match_idx = 1 : num_matches
				feature_value = EM_trace(match_idcs(match_idx));

				% in the Shiffrin paper, this is the product on the right half of the right hand side of equation A7 
				p_old_given_data = p_old_given_data * (c + (1-c)*geometric_dist_p*(1-geometric_dist_p)^(feature_value-1));
				p_new_given_data = p_new_given_data * (geometric_dist_p*(1-geometric_dist_p)^(feature_value-1)) ;
			end
			num_mismatches = numel(EM_trace) - num_matches;
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



