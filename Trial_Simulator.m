classdef Trial_Simulator
	properties
		
		%%%%%%%%%%%%%%%%%%%%
		% STATE variables
		%%%%%%%%%%%%%%%%%%%%
		REMsim;
		% this will hold the odds ratio for each item presented
		EMpresentationStrengthsPerTrial={};
		% this will specify whether the presented item is a target or not
		presentationTargetIndicator={};
		% this will specify the prob old for the item presented
		EMpresentationProbOld={};
		% this will specify the prob new for the item presented
		EMpresentationProbNew={};
		tid = '1';
		currentTrial = 0;
		% this will contain the EM strengths for past lures
		EMpastLureStrengthsPerTrial={};
		% this will contain the EM strengths for past targets
		EMpastTargetsStrengthsPerTrial={};
		% here we'll hold the context vectors across all trials
		contextVectors = [];
		% this will hold the odds ratio for each item presented
		WMpresentationStrengthsPerTrial={};
		% this will contain the EM strengths for past lures
		WMpastLureStrengthsPerTrial={};
		% this will contain the EM strengths for past targets
		WMpastTargetsStrengthsPerTrial={};
		WMrehearsalAttemptsPerTrial={};
		WMrehearsalFailuresPerTrial={};
		% this keeps track of how many features were decayed
		WMdecayedFeatures={};

		%%%%%%%%%%%%%%%%%%%%
		% SETTINGS variables
		%%%%%%%%%%%%%%%%%%%%
		numTrials = 1000;
		numUniqueItems = 100;
		numSamplesPerPresentationTarget = 10;
		targetsPerTrial = [];
		itemPresentationsPerTrial = [];
        turnOffWMdecay = false;
        turnOffWMrehearsal = false;
	end

	% properties(Constant = true);
	% 	% this tells us the name of the .mat file to look for 
	% 	% which stores values
	% 	SETTINGS_MAT_FILE = 'EM_trial_simulations.mat';
	% end

	methods
		function this = Trial_Simulator()
			this = load_settings_if_present(this);
		end

		function this = ILL_SIM_YOU_LATER(this)
			% initialize our simulator and the list items
			this.REMsim = REMplusWM(this.numUniqueItems,this.tid);

            if this.turnOffWMdecay
                this.REMsim = this.REMsim.turnOffWMdecay;
            end

            if this.turnOffWMrehearsal
				this.REMsim = this.REMsim.turnOffWMrehearsal;
			end
            
			for trial = 1 : this.numTrials
				this.currentTrial = trial;

				% setup trial by specifying target_idx
				target_idx = this.targetsPerTrial(trial);
				this.REMsim = this.REMsim.setupNewTrial(target_idx);
				num_presentations = numel(this.itemPresentationsPerTrial{trial});
				this.contextVectors(:,trial) = this.REMsim.currentContext();
                
                this.WMpastLureStrengthsPerTrial{trial} = [];
                this.EMpastLureStrengthsPerTrial{trial} = [];
                this.WMpastTargetsStrengthsPerTrial{trial} = [];
                this.EMpastTargetsStrengthsPerTrial{trial} = [];

				% here we present the images for this trial and store all the info
				for presentation_idx = 1 : num_presentations
					presented_item_idx = this.itemPresentationsPerTrial{trial}(presentation_idx);

					% update trial time for WM
					this.REMsim = this.REMsim.updateTrialTime();
					[this.REMsim this.WMdecayedFeatures{trial}(presentation_idx)] = this.REMsim.decayWMtrace();

					% perform rehearsal if needed
					[this.REMsim this.WMrehearsalAttemptsPerTrial{trial}(presentation_idx) ...
				   		this.WMrehearsalFailuresPerTrial{trial}(presentation_idx)] = this.REMsim.updateWMifNeeded();

					% get EM signal
					[this.EMpresentationStrengthsPerTrial{trial}(presentation_idx), this.EMpresentationProbOld{trial}(presentation_idx), ...
						this.EMpresentationProbNew{trial}(presentation_idx)] = this.REMsim.getOddsRatioForItemIdx(presented_item_idx);

					% get WM signal
					[this.WMpresentationStrengthsPerTrial{trial}(presentation_idx)] = this.REMsim.probeWM(presented_item_idx);

					% this should always be the last item presented that gets recorded as the target, but let's just go ahead and make sure we're doing what we think we're doing with this check
					if presented_item_idx == target_idx
						this.presentationTargetIndicator{trial}(presentation_idx) = 1;
						this.WMpastTargetsStrengthsPerTrial{trial}(end+1) = this.WMpresentationStrengthsPerTrial{trial}(presentation_idx);
						this.EMpastTargetsStrengthsPerTrial{trial}(end+1) = this.EMpresentationStrengthsPerTrial{trial}(presentation_idx);
					else
						this.WMpastLureStrengthsPerTrial{trial}(end+1) = this.WMpresentationStrengthsPerTrial{trial}(presentation_idx);
						this.EMpastLureStrengthsPerTrial{trial}(end+1) = this.EMpresentationStrengthsPerTrial{trial}(presentation_idx);
					end
				end

				if mod(trial,50) == 0
					disp(['Current trial: ' num2str(trial)]);
				end

			end
			save_file = ['EM_sim_results_' this.tid '.mat'];
			save(save_file,'this','-v7.3');
			% we also save a barebones version
			save_file = ['EM_sim_results_' this.tid 'barebones.mat'];
			p_old = this.EMpresentationProbOld;
			p_new = this.EMpresentationProbNew;
			p_target_indicator = this.presentationTargetIndicator;
			save(save_file,'p_old','p_new','p_target_indicator','-v7.3');
		end

		function this = load_settings_if_present(this)
			tid = getenv('SGE_TASK_ID');
			% checking to see if this affects the issue on the cluster
			% where jobs will be running - but
			%pause(mod(str2num(tid),50));
			if ~isempty(tid) && exist(PM_task.SETTINGS_MAT_FILE,'file')
				this.tid = tid;
				load(PM_task.SETTINGS_MAT_FILE);
				this.numTrials = numel(targets);
				this.numUniqueItems = numUniqueItems;
				this.targetsPerTrial = targets;
				this.itemPresentationsPerTrial = item_presentations_per_trial;
				this.EMpresentationStrengthsPerTrial = cell(1,this.numTrials);
				this.presentationTargetIndicator = cell(1,this.numTrials);
				this.EMpresentationProbOld = cell(1,this.numTrials);
				this.EMpresentationProbNew = cell(1,this.numTrials);

				% now we initialize our values based on each 
				% THERE ARE TWO LEVELS OF INITIALIZATION:
				% general setttings for REM.m
				% and simulation specific values such as what our per trial targets and non-targets are
			end
		end

	end
end



