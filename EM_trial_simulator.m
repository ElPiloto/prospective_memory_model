classdef EM_trial_simulator
	properties
		
		%%%%%%%%%%%%%%%%%%%%
		% STATE variables
		%%%%%%%%%%%%%%%%%%%%
		EMsim;
		targetStrengths = [];
		lureStrengths = [];
		tid = '1';
		currentTrial = 0;
		
		%%%%%%%%%%%%%%%%%%%%
		% SETTINGS variables
		%%%%%%%%%%%%%%%%%%%%
		numTrials = 1000;
		numUniqueItems = 100;
		numSamplesPerPresentationTarget = 10;
		targetsPerTrial = [];
		luresPerTrial = [];
	end

	% properties(Constant = true);
	% 	% this tells us the name of the .mat file to look for 
	% 	% which stores values
	% 	SETTINGS_MAT_FILE = 'EM_trial_simulations.mat';
	% end

	methods
		function this = EM_trial_simulator()
			this = load_settings_if_present(this);
			this.targetStrengths = zeros(this.numTrials,this.numSamplesPerPresentationTarget);
			this.lureStrengths = zeros(this.numTrials,this.numSamplesPerPresentationTarget);
		end

		function this = ILL_SIM_YOU_LATER(this)
			% initialize our simulator and the list items
			this.EMsim = REM(this.numTrials,this.tid);

			for trial = 1 : this.numTrials
				this.currentTrial = trial;
				target_idx = this.targetsPerTrial(trial);
				lure_idx = this.luresPerTrial(trial);

				this.EMsim = this.EMsim.setupNewTrial(target_idx);

				for sample_idx = 1 : this.numSamplesPerPresentationTarget
					% actually grab the memory strengths
					this.targetStrengths(trial, sample_idx) = this.EMsim.getOddsRatioForItemIdx(target_idx);
					this.lureStrengths(trial, sample_idx) = this.EMsim.getOddsRatioForItemIdx(lure_idx);

					% this will force us to re-encode our target, giving us a new sample for the next iteration
					% NOTE: REMEMBER THAT THIS CODE WORKS AS INTENDED ONLY IF WE REPLACE EXISTING MEMORY TRACES FOR
					% THE SAME ITEM WHEN WE ENCODE
					this.EMsim = this.EMsim.encode(target_idx);
				end
				if mod(trial,10) == 0
					disp(['Current trial: ' num2str(trial)]);
				end

			end
			save_file = ['EM_sim_results_' this.tid '.mat'];
			targetStrengths = this.targetStrengths;
			lureStrengths = this.lureStrengths;
			save(save_file,'targetStrengths','lureStrengths','-v7.3');
		end

		% TO-DO: FINISH THIS TO ACTUALLY LOAD SHIT UP!!!!!!
		function this = load_settings_if_present(this)
			tid = getenv('SGE_TASK_ID');
			if ~isempty(tid) && exist(PM_task.SETTINGS_MAT_FILE,'file')
				this.tid = tid;
				load(PM_task.SETTINGS_MAT_FILE);
				this.numTrials = numel(targets);
				this.targetsPerTrial = targets;
				this.luresPerTrial = lures;
				% now we initialize our values based on each 
				% THERE ARE TWO LEVELS OF INITIALIZATION:
				% general setttings for REM.m
				% and simulation specific values such as what our per trial targets and non-targets are
			end
		end

	end
end



