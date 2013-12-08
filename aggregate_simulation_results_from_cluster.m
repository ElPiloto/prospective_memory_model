
filename_template = '/fastscratch/lpiloto/prosp_mem/EM_sim_results_*.mat';

this_batch = ['/fastscratch/lpiloto/prosp_mem/' datestr(now,30)];
mkdir(this_batch);
unix(['mv /fastscratch/lpiloto/prosp_mem/*barebones.mat ' this_batch]);

saved_files = dir(filename_template);

num_files = numel(saved_files);


% note that this doesn't enforce a correspondence between file_num and simulation number,
% but we don't need that for the current code
for file_num = 1 : num_files
	load(['/fastscratch/lpiloto/prosp_mem/' saved_files(file_num).name]);

	% simply take the first Trial_Simulator result and make that our aggrergated result to which we'll append subsequent date
	if file_num == 1
        for trial = 1 : this.numTrials
            aggResults.numTrials = this.numTrials;
            aggResults.WMdecayedFeatures{trial} = this.WMdecayedFeatures{trial};
            aggResults.WMrehearsalFailuresPerTrial{trial} =  this.WMrehearsalFailuresPerTrial{trial};
            aggResults.WMpresentationStrengthsPerTrial{trial} =  this.WMpresentationStrengthsPerTrial{trial};
            aggResults.EMpresentationStrengthsPerTrial{trial} =  this.EMpresentationStrengthsPerTrial{trial};
            aggResults.EMpastLureStrengthsPerTrial{trial} =  this.EMpastLureStrengthsPerTrial{trial};
            aggResults.WMpastLureStrengthsPerTrial{trial} =  this.WMpastLureStrengthsPerTrial{trial};
            aggResults.EMpastTargetsStrengthsPerTrial{trial} =  this.EMpastTargetsStrengthsPerTrial{trial};
            aggResults.WMpastTargetsStrengthsPerTrial{trial} =  this.WMpastTargetsStrengthsPerTrial{trial};
            aggResults.WMrehearsalAttemptsPerTrial{trial} = this.WMrehearsalAttemptsPerTrial{trial};
            aggResults.presentationTargetIndicator{trial} = this.presentationTargetIndicator{trial};
        end

    else

        for trial = 1 : this.numTrials
            % do an inplace average for all the things we want to store
            aggResults.WMdecayedFeatures{trial} = (aggResults.WMdecayedFeatures{trial}*(file_num-1) + this.WMdecayedFeatures{trial})/(file_num);
            aggResults.WMrehearsalFailuresPerTrial{trial} = (aggResults.WMrehearsalFailuresPerTrial{trial}*(file_num-1) + this.WMrehearsalFailuresPerTrial{trial})/(file_num);
            aggResults.WMpresentationStrengthsPerTrial{trial} = (aggResults.WMpresentationStrengthsPerTrial{trial}*(file_num-1) + this.WMpresentationStrengthsPerTrial{trial})/(file_num);
            aggResults.EMpresentationStrengthsPerTrial{trial} = (aggResults.EMpresentationStrengthsPerTrial{trial}*(file_num-1) + this.EMpresentationStrengthsPerTrial{trial})/(file_num);
            aggResults.EMpastLureStrengthsPerTrial{trial} = (aggResults.EMpastLureStrengthsPerTrial{trial}*(file_num-1) + this.EMpastLureStrengthsPerTrial{trial})/(file_num);
            aggResults.WMpastLureStrengthsPerTrial{trial} = (aggResults.WMpastLureStrengthsPerTrial{trial}*(file_num-1) + this.WMpastLureStrengthsPerTrial{trial})/(file_num);
            aggResults.EMpastTargetsStrengthsPerTrial{trial} = (aggResults.EMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + this.EMpastTargetsStrengthsPerTrial{trial})/(file_num);
            aggResults.WMpastTargetsStrengthsPerTrial{trial} = (aggResults.WMpastTargetsStrengthsPerTrial{trial}*(file_num-1) + this.WMpastTargetsStrengthsPerTrial{trial})/(file_num);

            % we're assuming these remain constant across all the simulations
            aggResults.WMrehearsalAttemptsPerTrial{trial} = this.WMrehearsalAttemptsPerTrial{trial};
            aggResults.presentationTargetIndicator{trial} = this.presentationTargetIndicator{trial};
        end
    end

end

this = aggResults;
save('aggregatedResults','this','-v7.3');
save('/fastscratch/lpiloto/prosp_mem/aggregatedResults.mat','this','-v7.3');


unix(['mv /fastscratch/lpiloto/prosp_mem/*.mat ' this_batch]);

str = input('Yo. Describe these results so you don''t have to fumble to interpret them later: ','s');
str = [str '\nSaved in: ' this_batch];
fid = fopen(fullfile([this_batch 'description.txt']),'w');
fprintf(fid,'%s', str);

fclose(fid);
