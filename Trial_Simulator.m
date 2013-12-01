classdef Trial_Simulator
	properties
		
		%%%%%%%%%%%%%%%%%%%%
		% STATE variables
		%%%%%%%%%%%%%%%%%%%%
		EMsim;
		% this will hold the odds ratio for each item presented
		EMpresentationStrengthsPerTrial={};
		% this will specify whether the presented item is a target or not
		EMpresentationTargetIndicator={};
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
		contextVectors = {};
		% 
		
		
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
		function this = Trial_Simulator()
			this = load_settings_if_present(this);
		end

		function this = ILL_SIM_YOU_LATER(this)
			% initialize our simulator and the list items
			this.EMsim = REM(this.numUniqueItems,this.tid);

			for trial = 1 : this.numTrials
				this.currentTrial = trial;

				% setup trial by specifying target_idx
				target_idx = this.targetsPerTrial(trial);
				this.EMsim = this.EMsim.setupNewTrial(target_idx);
				num_presentations = numel(this.itemPresentationsPerTrial{trial});

				% here we present the images for this trial and store all the info
				for presentation_idx = 1 : num_presentations
					presented_item_idx = this.itemPresentationsPerTrial{trial}(presentation_idx);
					[this.EMpresentationStrengthsPerTrial{trial}(presentation_idx), this.EMpresentationProbOld{trial}(presentation_idx), ...
						this.EMpresentationProbNew{trial}(presentation_idx)] = this.EMsim.getOddsRatioForItemIdx(presented_item_idx);

					% this should always be the last one, but let's just go ahead and make sure we're doing what we think we're doing with this check
					if presented_item_idx == target_idx
						this.EMpresentationTargetIndicator{trial}(presentation_idx) = 1;
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
			p_target_indicator = this.EMpresentationTargetIndicator;
			save(save_file,'p_old','p_new','p_target_indicator','-v7.3');
		end

		function this = load_settings_if_present(this)
			tid = getenv('SGE_TASK_ID');
			if ~isempty(tid) && exist(PM_task.SETTINGS_MAT_FILE,'file')
				this.tid = tid;
				load(PM_task.SETTINGS_MAT_FILE);
				this.numTrials = numel(targets);
				this.numUniqueItems = numUniqueItems;
				this.targetsPerTrial = targets;
				this.itemPresentationsPerTrial = item_presentations_per_trial;
				this.EMpresentationStrengthsPerTrial = cell(1,this.numTrials);
				this.EMpresentationTargetIndicator = cell(1,this.numTrials);
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



