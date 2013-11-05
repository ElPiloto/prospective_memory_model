% this class is just being used as a convenient way of encapsulating functionality,
% not for any object functionality
classdef PM_task
	properties(Constant = true)
		numSimulations = 20000;
		numTrials = 1000;
		maxPresentationsPerTrial = 15;
		numUniqueItems = 100;
		numSamplesPerPresentation = 10;
		SETTINGS_MAT_FILE = 'EM_trial_simulations.mat';
	end

	methods(Static = true)
		% this function 
		function [] = generateSimulationTargetsAndLures(numTrials,numUniqueItems,numSimulations)
			targets = zeros(1,numTrials);
			item_presentations_per_trial = cell(1,numTrials);

			% general gist is to select a random number of presentations for a trial, then randomly select that many items for the trial
			% and set the target to be the last item for for that trial
			for trial = 1 : numTrials
				% select how many images will be presented on this trial
				num_presentations = randi(PM_task.maxPresentationsPerTrial);
				% generate sequence of images
				item_presentations_per_trial{trial} = randsample(numUniqueItems,num_presentations);
				% grab last presented item
				targets(trial) = item_presentations_per_trial{trial}(end);
			end

			save(PM_task.SETTINGS_MAT_FILE,'-v7.3');
		end

		function [] = launchSimulationsAfterGenerating()
			if exist(PM_task.SETTINGS_MAT_FILE,'file')
				load(PM_task.SETTINGS_MAT_FILE);

				% here is the rondo command we'll run
				unix(sprintf('submit -tc 50 %s EM_trial_launcher.m ',numSimulations));
			else
				error(['No simulation settings saved to ' PM_task.SETTINGS_MAT_FILE]);
			end
		end


	end
end



