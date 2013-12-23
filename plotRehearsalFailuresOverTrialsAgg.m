function [ avg_rehearsal_failures ] = plotRehearsalFailuresOverTrials( simulations, smooth_size)
% [  ] = PLOTREHEARSALFAILURESOVERTRIALS(simulations)
% Purpose
%
% This function expects a struct array returned by aggrage_sim_results_from_cluster,
% where each entry in the struct array is the result of a single simulations.
%
% INPUT
%
% simulations - a trial simulator object 
% smooth_size - can be either empty or 0(no smoothing), a positive integer for smoothing, or 'auto'
% 				to specify smoothing with window = 20% of number of trials
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% plotRehearsalFailuresOverTrials(simulations)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_simulations = numel(simulations);

if nargin < 2
	smooth_size = 0;
end

avg_rehearsal_failures = [];
first_failures = [];
for simulation_idx = 1 : num_simulations

	for trial_number = 1 : simulations(1).numTrials
        attemptFailures = simulations(simulation_idx).WMrehearsalFailuresPerTrial{trial_number}(simulations(simulation_idx).WMrehearsalAttemptsPerTrial{trial_number});
        % only count the number of failures up to the first failure:
        % e.g.: given rehearsal failure as: [0 0 1 1], we want this to be
        % 1/3 because of the 3 times we had the correct memory in WM, we
        % failed only once;
        % there's a clever way to do this with binary but i'm not gunna do
        % it right now and i don't think it's more efficient anyway;
        firstFailure = min(find(attemptFailures));
        if isempty(firstFailure)
            avg_rehearsal_failures(simulation_idx,trial_number) = 0;
        else
            avg_rehearsal_failures(simulation_idx,trial_number) = 1/firstFailure;
            first_failures(end+1) = firstFailure;
        end

	end
end

%figure(8);
if smooth_size == 0
	plot(mean(avg_rehearsal_failures,1));
else
	if isstr(smooth_size)
		plot(smooth(mean(avg_rehearsal_failures,1),floor(simulations.numTrials * 0.2)));
	elseif isinteger(smooth_size) && smooth_size > 0
		plot(smooth(mean(avg_rehearsal_failures,1),smooth_size));
	end
end
xlabel('Trial Number');
ylabel('% Failures In Trials');
title('How often rehearsal retrieved different trace than WM trace');
ylim([0 1]);

end
