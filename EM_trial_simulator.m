classdef EM_trial_simulator
	properties
		
		%%%%%%%%%%%%%%%%%%%%
		% STATE variables
		%%%%%%%%%%%%%%%%%%%%
		EMsim;
		% this will hold the odds ratio for each item presented
		presentationStrengthsPerTrial={};
		% this will specify whether the presented item is a target or not
		presentationTargetIndicator={};
		% this will specify the prob old for the item presented
		presentationProbOld={};
		% this will specify the prob new for the item presented
		presentationProbNew={};
		tid = '1';
		currentTrial = 0;
		
		%%%%%%%%%%%%%%%%%%%%
		% SETTINGS variables
		%%%%%%%%%%%%%%%%%%%%
		numTrials = 1000;
		numUniqueItems = 100;
		numSamplesPerPresentationTarget = 10;
		targetsPerTrial = [];
		itemPresentationsPerTrial = [];
	end

	% properties(Constant = true);
	% 	% this tells us the name of the .mat file to look for 
	% 	% which stores values
	% 	SETTINGS_MAT_FILE = 'EM_trial_simulations.mat';
	% end

	methods
		function this = EM_trial_simulator()
			this = load_settings_if_present(this);
		end

		function this = ILL_SIM_YOU_LATER(this)
			% initialize our simulator and the list items
			this.EMsim = REM(this.numTrials,this.tid);

			for trial = 1 : this.numTrials
				this.currentTrial = trial;

				% setup trial by specifying target_idx
				target_idx = this.targetsPerTrial(trial);
				this.EMsim = this.EMsim.setupNewTrial(target_idx);
				num_presentations = numel(this.itemPresentationsPerTrial{trial});

				for presentation_idx = 1 : num_presentations
					presented_item_idx = this.itemPresentationsPerTrial{trial}(presentation_idx);
					[this.presentationStrengthsPerTrial{trial}(presentation_idx), this.presentationProbOld{trial}(presentation_idx), ...
						this.presentationProbNew{trial}(presentation_idx)] = this.EMsim.getOddsRatioForItemIdx(presented_item_idx);

					% this should always be the last one, but let's just go ahead and make sure we're doing what we think we're doing with this check
					if presented_item_idx == target_idx
						this.presentationTargetIndicator{trial}(presentation_idx) = 1;
					end
				end

				if mod(trial,50) == 0
					disp(['Current trial: ' num2str(trial)]);
				end

			end
			save_file = ['EM_sim_results_' this.tid '.mat'];
			save(save_file,'this','-v7.3');
		end

		function this = load_settings_if_present(this)
			tid = getenv('SGE_TASK_ID');
			if ~isempty(tid) && exist(PM_task.SETTINGS_MAT_FILE,'file')
				this.tid = tid;
				load(PM_task.SETTINGS_MAT_FILE);
				this.numTrials = numel(targets);
				this.targetsPerTrial = targets;
				this.itemPresentationsPerTrial = item_presentations_per_trial;
				this.presentationStrengthsPerTrial = cell(1,this.numTrials);
				this.presentationTargetIndicator = cell(1,this.numTrials);
				this.presentationProbOld = cell(1,this.numTrials);
				this.presentationProbNew = cell(1,this.numTrials);

				% now we initialize our values based on each 
				% THERE ARE TWO LEVELS OF INITIALIZATION:
				% general setttings for REM.m
				% and simulation specific values such as what our per trial targets and non-targets are
			end
		end

	end
end



