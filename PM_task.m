% this class is just being used as a convenient way of encapsulating functionality,
% not for any object functionality
classdef PM_task
	properties(Constant = true)
		numSimulations = 20000;
		numTrials = 1000;
		maxPresentationsPerTrial = 10;
		numUniqueItems = 20;
		sameNumPresentations = true;
		SETTINGS_MAT_FILE = 'EM_trial_simulations.mat';
		SAVE_DIRECTORY = '/fastscratch/lpiloto/prosp_mem/';
	end

	methods(Static = true)
		% this function 
		function [] = generateSimulationTargetsAndLures(numTrials,numUniqueItems,numSimulations,maxPresentationsPerTrial)
			if nargin < 4
				maxPresentationsPerTrial = PM_task.maxPresentationsPerTrial;
			end

			item_presentations_per_trial = cell(1,numTrials);

			targets = PM_task.chooseTargets(numUniqueItems,numTrials);
			for trial = 1 : numTrials
				if PM_task.sameNumPresentations
					num_presentations = maxPresentationsPerTrial;
				else
					% select how many images will be presented on this trial
					num_presentations = randi(maxPresentationsPerTrial);
				end

				item_presentations_per_trial{trial} = PM_task.choosePresentation(numUniqueItems,num_presentations,targets(trial));
			end

			save(PM_task.SETTINGS_MAT_FILE,'-v7.3');
		end

		function [] = launchSimulationsAfterGenerating()
			if exist(PM_task.SETTINGS_MAT_FILE,'file')
				load(PM_task.SETTINGS_MAT_FILE);

				% here is the rondo command we'll run
				unix(sprintf('submit -tc 60 %s EM_trial_launcher.m ',numSimulations));
			else
				error(['No simulation settings saved to ' PM_task.SETTINGS_MAT_FILE]);
			end
		end

		function [] = launchSimulationsAfterGeneratingLocalOrCluster(scriptName)
			if exist(PM_task.SETTINGS_MAT_FILE,'file')
				load(PM_task.SETTINGS_MAT_FILE);
			end
			[~,compName] = system('hostname');
			onCluster = strmatch('node',compName);
			if onCluster
				unix(sprintf('submit -tc 60 %d %s.m ',numSimulations,scriptName));
			else
				setenv('SGE_TASK_ID','1');
				eval(scriptName);
			end

		end

		function [] = runInCurrentMatlabEvenIfOnCluster(scriptName)
			if exist(PM_task.SETTINGS_MAT_FILE,'file')
				load(PM_task.SETTINGS_MAT_FILE);
			end

			setenv('SGE_TASK_ID','1');
			shouldExitIfOnCluster = false;
			eval(scriptName);

		end

		function [targets] = chooseTargets(numUniqueItems, numTrials)
			% this function ensures that we get the most uniform number of item targets possible

			% numTrials = how many targets to choose
			targets = [];

			% how many full sets of numUnique items can we fit into numTrials?
			max_unique_repetitions = floor(numTrials / numUniqueItems);

			% how many leftover where we can only get some
			remainder_targets = numTrials - max_unique_repetitions * numUniqueItems;

			for repetition = 1 : max_unique_repetitions
				targets = [targets randperm(numUniqueItems)];
			end

			% here we add the leftover, if any
			if remainder_targets > 0
				targets = [targets randsample(numUniqueItems,remainder_targets,false)'];
			end
		end

		function [item_presentations] = choosePresentation(numUniqueItems,numPresentations,current_target)

            if numUniqueItems < numPresentations
                throw(MException('PM_task:InvalidPM_taskParameters','Num Unique Items is less than the number of presentations'));
            end
            
			if current_target == 1
				to_shuffle = 2:numUniqueItems;
			elseif current_target == numUniqueItems
				to_shuffle =  1:(numUniqueItems-1);
			else
				to_shuffle = [1:(current_target-1) (current_target+1):numUniqueItems];
			end

			% select however many we're going to use on each trial minus 1 to leave room for the target we already specified
			to_shuffle = randsample(to_shuffle,numPresentations-1,false);
			item_presentations = [to_shuffle(randperm(numel(to_shuffle))) current_target]; % this ensures the target is the last one

		end


	end
end



