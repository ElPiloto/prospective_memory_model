
filename_template = fullfile(PM_task.SAVE_DIRECTORY,'sim_results_*.mat');

rng('shuffle');

% we add a random lowercase letter to each batch along with the date time in order to identify it
% the random letter just makes it easier to read the .mat names later on
random_letter = char(randi(90-65) + 65);
this_batch = fullfile(PM_task.SAVE_DIRECTORY, [random_letter datestr(now,30)]);
mkdir(this_batch);
unix(['mv ' fullfile(PM_task.SAVE_DIRECTORY,'*barebones.mat ') this_batch]);

saved_files = dir(filename_template);

num_files = numel(saved_files);


% note that this doesn't enforce a correspondence between file_num and simulation number,
% but we don't need that for the current code
for file_num = 1 : num_files
	load(fullfile(PM_task.SAVE_DIRECTORY saved_files(file_num).name));

	% simply take the first Trial_Simulator result and make that our aggrergated result to which we'll append subsequent date
	if file_num == 1
        for trial = 1 : trial_simulation.numTrials
            collapsedAggResults.numTrials = trial_simulation.numTrials;
            collapsedAggResults.WMdecayedFeatures{trial} = trial_simulation.WMdecayedFeatures{trial};
            collapsedAggResults.WMrehearsalFailuresPerTrial{trial} =  trial_simulation.WMrehearsalFailuresPerTrial{trial};
            collapsedAggResults.WMpresentationStrengthsPerTrial{trial} =  trial_simulation.WMpresentationStrengthsPerTrial{trial};
            collapsedAggResults.EMpresentationStrengthsPerTrial{trial} =  trial_simulation.EMpresentationStrengthsPerTrial{trial};
            collapsedAggResults.EMpastLureStrengthsPerTrial{trial} =  trial_simulation.EMpastLureStrengthsPerTrial{trial};
            collapsedAggResults.WMpastLureStrengthsPerTrial{trial} =  trial_simulation.WMpastLureStrengthsPerTrial{trial};
            collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial} =  trial_simulation.EMpastTargetsStrengthsPerTrial{trial};
            collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial} =  trial_simulation.WMpastTargetsStrengthsPerTrial{trial};
            collapsedAggResults.WMrehearsalAttemptsPerTrial{trial} = trial_simulation.WMrehearsalAttemptsPerTrial{trial};
            collapsedAggResults.presentationTargetIndicator{trial} = trial_simulation.presentationTargetIndicator{trial};
        end

    else

        for trial = 1 : trial_simulation.numTrials
            % do an inplace average for all the things we want to store
            collapsedAggResults.WMdecayedFeatures{trial} = (collapsedAggResults.WMdecayedFeatures{trial}*(file_num-1) + trial_simulation.WMdecayedFeatures{trial})/(file_num);
            collapsedAggResults.WMrehearsalFailuresPerTrial{trial} = (collapsedAggResults.WMrehearsalFailuresPerTrial{trial}*(file_num-1) + trial_simulation.WMrehearsalFailuresPerTrial{trial})/(file_num);
            collapsedAggResults.WMpresentationStrengthsPerTrial{trial} = (collapsedAggResults.WMpresentationStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.WMpresentationStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpresentationStrengthsPerTrial{trial} = (collapsedAggResults.EMpresentationStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.EMpresentationStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpastLureStrengthsPerTrial{trial} = (collapsedAggResults.EMpastLureStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.EMpastLureStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.WMpastLureStrengthsPerTrial{trial} = (collapsedAggResults.WMpastLureStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.WMpastLureStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial} = (collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.EMpastTargetsStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial} = (collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + trial_simulation.WMpastTargetsStrengthsPerTrial{trial})/(file_num);

            % we're assuming these remain constant across all thesimulations
            collapsedAggResults.WMrehearsalAttemptsPerTrial{trial} = trial_simulation.WMrehearsalAttemptsPerTrial{trial};
            collapsedAggResults.presentationTargetIndicator{trial} = trial_simulation.presentationTargetIndicator{trial};
        end
    end

end

save('collapsedAggregatedResults','collapsedAggResults','-v7.3');
save(fullfile(PM_task.SAVE_DIRECTORY,'collapsedAggregatedResults.mat'),'collapsedAggResults','-v7.3');


unix(['mv ' fullfile(PM_task.SAVE_DIRECTORY,'*.mat') ' ' this_batch]);

str = input('Yo. Describe these results so you don''t have to fumble to interpret them later: ','s');
str = [str '\nSaved in: ' this_batch];
fid = fopen(fullfile([this_batch 'description.txt']),'w');
fprintf(fid,'%s', str);

fclose(fid);
