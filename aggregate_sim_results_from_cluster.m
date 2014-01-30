if ~exist('NO_DESCRIPTION','var')
	% this indicates that we want to run this but we don't want it to wait on our description of the results
	NO_DESCRIPTION = true;
end

if ~exist('PLOT_AUC','var')
	PLOT_AUC = false
end

filename_template = fullfile(PM_task.SAVE_DIRECTORY,'sim_results_*.mat');

% set the matlab random number generator seed to something unique so that our attempts to add random
% letters for each set of results aren't thwarted by matlab's idiotic behavior of always starting with
% the same exact rng seed
rng('shuffle');

% we add a random lowercase letter to each batch along with the date time in order to identify it
% the random letter just makes it easier to read the .mat names later on
random_letter = char(randi(90-65) + 65);
this_batch_timestamp = [random_letter datestr(now,30)];
this_batch = [PM_task.SAVE_DIRECTORY this_batch_timestamp];
mkdir(this_batch);
unix(['mv ' PM_task.SAVE_DIRECTORY '*barebones.mat ' this_batch]);

saved_files = dir(filename_template);

num_files = numel(saved_files);


% note that this doesn't enforce a correspondence between file_num and simulation number,
% but we don't need that for the current code
result_idx = 0;
for file_num = 1 : num_files
	try
		load([PM_task.SAVE_DIRECTORY saved_files(file_num).name]);
		result_idx = result_idx + 1;
	catch
		unix(['rm ' PM_task.SAVE_DIRECTORY saved_files(file_num).name]);
		% remove the problematic file and go to next file!
		continue;
	end

	% give folders more descriptive file names
	if ~exist('beter_dir_name','var')
		if trial_simulation.turnOffWMrehearsal
			better_dir_name = 'rehearseNO';
		else
			if isnan(trial_simulation.minimumRetrievedLogStrengthWM)
				better_dir_name = 'rehearseYES';
			else
				better_dir_name = 'rehearseREJECT';
			end
		end
		if trial_simulation.turnOffWMdecay
			better_dir_name = [better_dir_name 'decayNO'];
		else
			better_dir_name = [better_dir_name 'decayYES'];
		end
		better_dir_name = [better_dir_name num2str(trial_simulation.numUniqueItems ) 'unqItems' num2str(floor(trial_simulation.REMsim.rehearsalFreqWM/trial_simulation.REMsim.timeBetweenPresentations)) 'rehearsefreq' ];
		% here we append the random character and time part of the datetime stamp to the better_dir_name
		better_dir_name = [this_batch_timestamp(1) this_batch_timestamp(end-6:end) '_' better_dir_name] ;
	end

	% store all results separately
	for trial = 1 : trial_simulation.numTrials
		aggResults(result_idx).numTrials = trial_simulation.numTrials;
		aggResults(result_idx).WMdecayedFeatures{trial} = trial_simulation.WMdecayedFeatures{trial};
		aggResults(result_idx).WMdidRehearsalMatchDifTrace{trial} =  trial_simulation.WMdidRehearsalMatchDifTrace{trial};
		aggResults(result_idx).WMpresentationStrengthsPerTrial{trial} =  trial_simulation.WMpresentationStrengthsPerTrial{trial};
		aggResults(result_idx).EMpresentationStrengthsPerTrial{trial} =  trial_simulation.EMpresentationStrengthsPerTrial{trial};
		aggResults(result_idx).EMpastLureStrengthsPerTrial{trial} =  trial_simulation.EMpastLureStrengthsPerTrial{trial};
		aggResults(result_idx).WMpastLureStrengthsPerTrial{trial} =  trial_simulation.WMpastLureStrengthsPerTrial{trial};
		aggResults(result_idx).EMpastTargetsStrengthsPerTrial{trial} =  trial_simulation.EMpastTargetsStrengthsPerTrial{trial};
		aggResults(result_idx).WMpastTargetsStrengthsPerTrial{trial} =  trial_simulation.WMpastTargetsStrengthsPerTrial{trial};
		aggResults(result_idx).WMrehearsalAttemptsPerTrial{trial} = trial_simulation.WMrehearsalAttemptsPerTrial{trial};
		aggResults(result_idx).presentationTargetIndicator{trial} = trial_simulation.presentationTargetIndicator{trial};
		aggResults(result_idx).WMrehearsalRightItemWrongContext{trial} = trial_simulation.WMrehearsalRightItemWrongContext{trial};
		aggResults(result_idx).WMrejectedRehearsal{trial} = trial_simulation.WMrejectedRehearsal{trial};
	end
	aggResults(result_idx).tid = trial_simulation.tid;
	aggResults(result_idx).targetsPerTrial = trial_simulation.targetsPerTrial;

	% simply take the first Trial_Simulator result and make that our aggrergated result to which we'll append subsequent data
	% and squash
	if result_idx == 1
        for trial = 1 : trial_simulation.numTrials
            collapsedAggResults.numTrials = trial_simulation.numTrials;
            collapsedAggResults.WMdecayedFeatures{trial} = trial_simulation.WMdecayedFeatures{trial};
            collapsedAggResults.WMdidRehearsalMatchDifTrace{trial} =  trial_simulation.WMdidRehearsalMatchDifTrace{trial};
            collapsedAggResults.WMpresentationStrengthsPerTrial{trial} =  trial_simulation.WMpresentationStrengthsPerTrial{trial};
            collapsedAggResults.EMpresentationStrengthsPerTrial{trial} =  trial_simulation.EMpresentationStrengthsPerTrial{trial};
            collapsedAggResults.EMpastLureStrengthsPerTrial{trial} =  trial_simulation.EMpastLureStrengthsPerTrial{trial};
            collapsedAggResults.WMpastLureStrengthsPerTrial{trial} =  trial_simulation.WMpastLureStrengthsPerTrial{trial};
            collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial} =  trial_simulation.EMpastTargetsStrengthsPerTrial{trial};
            collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial} =  trial_simulation.WMpastTargetsStrengthsPerTrial{trial};
            collapsedAggResults.WMrehearsalAttemptsPerTrial{trial} = trial_simulation.WMrehearsalAttemptsPerTrial{trial};
            collapsedAggResults.presentationTargetIndicator{trial} = trial_simulation.presentationTargetIndicator{trial};
      		collapsedAggResults(result_idx).WMrehearsalRightItemWrongContext{trial} = trial_simulation.WMrehearsalRightItemWrongContext{trial};
      		collapsedAggResults(result_idx).WMrejectedRehearsal{trial} = trial_simulation.WMrejectedRehearsal{trial};
  		end

		collapsedAggResults(result_idx).targetsPerTrial = trial_simulation.targetsPerTrial;
    else

        for trial = 1 : trial_simulation.numTrials
            % do an inplace average for all the things we want to store
            collapsedAggResults.WMdecayedFeatures{trial} = (collapsedAggResults.WMdecayedFeatures{trial}*(file_num-1) + trial_simulation.WMdecayedFeatures{trial})/(file_num);
            collapsedAggResults.WMdidRehearsalMatchDifTrace{trial} = (collapsedAggResults.WMdidRehearsalMatchDifTrace{trial}*(file_num-1) + trial_simulation.WMdidRehearsalMatchDifTrace{trial})/(file_num);
            collapsedAggResults.WMpresentationStrengthsPerTrial{trial} = (collapsedAggResults.WMpresentationStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.WMpresentationStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpresentationStrengthsPerTrial{trial} = (collapsedAggResults.EMpresentationStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.EMpresentationStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpastLureStrengthsPerTrial{trial} = (collapsedAggResults.EMpastLureStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.EMpastLureStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.WMpastLureStrengthsPerTrial{trial} = (collapsedAggResults.WMpastLureStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.WMpastLureStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial} = (collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.EMpastTargetsStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial} = (collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.WMpastTargetsStrengthsPerTrial{trial})/(file_num);
      		collapsedAggResults(result_idx).WMrehearsalRightItemWrongContext{trial} = (collapsedAggResults.WMrehearsalRightItemWrongContext{trial}*(file_num-1) + trial_simulation.WMrehearsalRightItemWrongContext{trial})/(file_num);
      		collapsedAggResults(result_idx).WMrejectedRehearsal{trial} = (collapsedAggResults.WMrejectedRehearsal{trial}*(file_num-1) + trial_simulation.WMrejectedRehearsal{trial})/(file_num);

            % we're assuming these remain constant across all the simulations
            collapsedAggResults.WMrehearsalAttemptsPerTrial{trial} = trial_simulation.WMrehearsalAttemptsPerTrial{trial};
            collapsedAggResults.presentationTargetIndicator{trial} = trial_simulation.presentationTargetIndicator{trial};
        end
    end

end

save('aggregatedResults','aggResults','-v7.3');
save(fullfile(PM_task.SAVE_DIRECTORY,'aggregatedResults.mat'),'aggResults','-v7.3');

save('collapsedAggResults','collapsedAggResults','-v7.3');
save(fullfile(PM_task.SAVE_DIRECTORY,'collapsedAggResults.mat'),'collapsedAggResults','-v7.3');

% move the individual simulation .mat files into a folder with the name for this batch
unix(['mv ' fullfile(PM_task.SAVE_DIRECTORY,'*.mat') ' ' this_batch]);

if ~NO_DESCRIPTION
 
 	str = input('Yo. Describe these results so you don''t have to fumble to interpret them later: ','s');
 	str = [str '\nSaved in: ' this_batch];
 	fid = fopen(fullfile(this_batch,'description.txt'),'w');
 	fprintf(fid,'%s', str);
 	
 	fclose(fid);
end

if PLOT_AUC
	plotAUCEMvsWMAggResults(aggResults);
end

% finally rename our folder
better_dir_name = fullfile(PM_task.SAVE_DIRECTORY, better_dir_name);
unix(['mv ' this_batch ' ' better_dir_name]);
