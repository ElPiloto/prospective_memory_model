% this class is just being used as a convenient way of encapsulating functionality,
% not for any object functionality
classdef PM_task
	properties(Constant = true)
		numSimulations = 20000;
		numTrials = 1000;
		numUniqueItems = 100;
		numSamplesPerPresentation = 10;
		SETTINGS_MAT_FILE = 'EM_trial_simulations.mat';
	end

	methods(Static = true)
		% this function 
		function [] = generateSimulationTargetsAndLures(numSimulations, numTrials,numUniqueItems,numSamplesPerPresentation)
			targets = randi(numUniqueItems,1,numTrials);
			lures = randi(numUniqueItems,1,numTrials);
			target_lure_matches = find(targets == lures);
			num_rerands = 0;
			while numel(target_lure_matches) ~= 0
				num_rerands = num_rerands + 1;
				lures(target_lure_matches) = randi(numUniqueItems,1,numel(target_lure_matches));
				target_lure_matches = find(targets == lures);
			end
			clear num_rerands; clear target_lure_matches;
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



