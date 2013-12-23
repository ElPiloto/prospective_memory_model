
filename_template = '/fastscratch/lpiloto/prosp_mem/EM_sim_results_*.mat';

% we add a random lowercase letter to each batch along with the date time in order to identify it
% the random letter just makes it easier to read the .mat names later on
random_letter = char(randi(90-65) + 65);
this_batch_timestamp = [random_letter datestr(now,30)];
this_batch = ['/fastscratch/lpiloto/prosp_mem/' this_batch_timestamp];
mkdir(this_batch);
unix(['mv /fastscratch/lpiloto/prosp_mem/*barebones.mat ' this_batch]);

saved_files = dir(filename_template);

num_files = numel(saved_files);


% note that this doesn't enforce a correspondence between file_num and simulation number,
% but we don't need that for the current code
result_idx = 0;
for file_num = 1 : num_files
	try
		load(['/fastscratch/lpiloto/prosp_mem/' saved_files(file_num).name]);
		result_idx = result_idx + 1;
	catch
		unix(['rm /fastscratch/lpiloto/prosp_mem/' saved_files(file_num).name]);
		% remove the problematic file and go to next file!
		continue;
	end

	% give folders more descriptive file names
	if ~exist('beter_dir_name','var')
		if this.turnOffWMrehearsal
			better_dir_name = 'rehearseNO';
		else
			better_dir_name = 'rehearseYES';
		end
		if this.turnOffWMdecay
			better_dir_name = [better_dir_name 'decayNO'];
		else
			better_dir_name = [better_dir_name 'decayYES'];
		end
		better_dir_name = [better_dir_name num2str(this.numUniqueItems ) 'unqItems' num2str(floor(this.REMsim.rehearsalFreqWM/this.REMsim.timeBetweenPresentations)) 'rehearsefreq' ];
		% here we append the random character and time part of the datetime stamp to the better_dir_name
		better_dir_name = [better_dir_name '_' this_batch_timestamp(1) this_batch_timestamp(end-6:end)];
	end

	% store all results separately
	for trial = 1 : this.numTrials
		aggResults(result_idx).numTrials = this.numTrials;
		aggResults(result_idx).WMdecayedFeatures{trial} = this.WMdecayedFeatures{trial};
		aggResults(result_idx).WMrehearsalFailuresPerTrial{trial} =  this.WMrehearsalFailuresPerTrial{trial};
		aggResults(result_idx).WMpresentationStrengthsPerTrial{trial} =  this.WMpresentationStrengthsPerTrial{trial};
		aggResults(result_idx).EMpresentationStrengthsPerTrial{trial} =  this.EMpresentationStrengthsPerTrial{trial};
		aggResults(result_idx).EMpastLureStrengthsPerTrial{trial} =  this.EMpastLureStrengthsPerTrial{trial};
		aggResults(result_idx).WMpastLureStrengthsPerTrial{trial} =  this.WMpastLureStrengthsPerTrial{trial};
		aggResults(result_idx).EMpastTargetsStrengthsPerTrial{trial} =  this.EMpastTargetsStrengthsPerTrial{trial};
		aggResults(result_idx).WMpastTargetsStrengthsPerTrial{trial} =  this.WMpastTargetsStrengthsPerTrial{trial};
		aggResults(result_idx).WMrehearsalAttemptsPerTrial{trial} = this.WMrehearsalAttemptsPerTrial{trial};
		aggResults(result_idx).presentationTargetIndicator{trial} = this.presentationTargetIndicator{trial};
	end
	aggResults(result_idx).tid = this.tid;
	aggResults(result_idx).targetsPerTrial = this.targetsPerTrial;

	% simply take the first Trial_Simulator result and make that our aggrergated result to which we'll append subsequent data
	% and squash
	if result_idx == 1
        for trial = 1 : this.numTrials
            collapsedAggResults.numTrials = this.numTrials;
            collapsedAggResults.WMdecayedFeatures{trial} = this.WMdecayedFeatures{trial};
            collapsedAggResults.WMrehearsalFailuresPerTrial{trial} =  this.WMrehearsalFailuresPerTrial{trial};
            collapsedAggResults.WMpresentationStrengthsPerTrial{trial} =  this.WMpresentationStrengthsPerTrial{trial};
            collapsedAggResults.EMpresentationStrengthsPerTrial{trial} =  this.EMpresentationStrengthsPerTrial{trial};
            collapsedAggResults.EMpastLureStrengthsPerTrial{trial} =  this.EMpastLureStrengthsPerTrial{trial};
            collapsedAggResults.WMpastLureStrengthsPerTrial{trial} =  this.WMpastLureStrengthsPerTrial{trial};
            collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial} =  this.EMpastTargetsStrengthsPerTrial{trial};
            collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial} =  this.WMpastTargetsStrengthsPerTrial{trial};
            collapsedAggResults.WMrehearsalAttemptsPerTrial{trial} = this.WMrehearsalAttemptsPerTrial{trial};
            collapsedAggResults.presentationTargetIndicator{trial} = this.presentationTargetIndicator{trial};
        end

		collapsedAggResults(result_idx).targetsPerTrial = this.targetsPerTrial;
    else

        for trial = 1 : this.numTrials
            % do an inplace average for all the things we want to store
            collapsedAggResults.WMdecayedFeatures{trial} = (collapsedAggResults.WMdecayedFeatures{trial}*(file_num-1) + this.WMdecayedFeatures{trial})/(file_num);
            collapsedAggResults.WMrehearsalFailuresPerTrial{trial} = (collapsedAggResults.WMrehearsalFailuresPerTrial{trial}*(file_num-1) + this.WMrehearsalFailuresPerTrial{trial})/(file_num);
            collapsedAggResults.WMpresentationStrengthsPerTrial{trial} = (collapsedAggResults.WMpresentationStrengthsPerTrial{trial}*(file_num-1) + this.WMpresentationStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpresentationStrengthsPerTrial{trial} = (collapsedAggResults.EMpresentationStrengthsPerTrial{trial}*(file_num-1) + this.EMpresentationStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpastLureStrengthsPerTrial{trial} = (collapsedAggResults.EMpastLureStrengthsPerTrial{trial}*(file_num-1) + this.EMpastLureStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.WMpastLureStrengthsPerTrial{trial} = (collapsedAggResults.WMpastLureStrengthsPerTrial{trial}*(file_num-1) + this.WMpastLureStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial} = (collapsedAggResults.EMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + this.EMpastTargetsStrengthsPerTrial{trial})/(file_num);
            collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial} = (collapsedAggResults.WMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + this.WMpastTargetsStrengthsPerTrial{trial})/(file_num);

            % we're assuming these remain constant across all the simulations
            collapsedAggResults.WMrehearsalAttemptsPerTrial{trial} = this.WMrehearsalAttemptsPerTrial{trial};
            collapsedAggResults.presentationTargetIndicator{trial} = this.presentationTargetIndicator{trial};
        end
    end

end

this = aggResults;
save('aggregatedResults','this','-v7.3');
save('/fastscratch/lpiloto/prosp_mem/aggregatedResults.mat','this','-v7.3');

this = collapsedAggResults;
save('collapsedAggResults','this','-v7.3');
save('/fastscratch/lpiloto/prosp_mem/collapsedAggResults.mat','this','-v7.3');

% move the individual simulation .mat files into a folder with the name for this batch
unix(['mv /fastscratch/lpiloto/prosp_mem/*.mat ' this_batch]);

str = input('Yo. Describe these results so you don''t have to fumble to interpret them later: ','s');
str = [str '\nSaved in: ' this_batch];
fid = fopen(fullfile(this_batch,'description.txt'),'w');
fprintf(fid,'%s', str);

fclose(fid);


% finally rename our folder
better_dir_name = ['/fastscratch/lpiloto/prosp_mem/' better_dir_name];
unix(['mv ' this_batch ' ' better_dir_name]);
