function [ percent_decay_trials_failed_rehearsal num_trials_with_decayed_feature failed_trials  ] = check_WM_decay_rehearsal_effect( simulation )
% [  ] = CHECK_WM_DECAY_REHEARSAL_EFFECT(simulation)
% Purpose
% 
% This function will go through a given simulation, find how often a 
% feature was decayed, and count the number of presentations until
% a rehearsal failure
%
% INPUT
%
% the result of running a simulation - Trial_Simulator object
%
% OUTPUT
% 
% shutup
%
% EXAMPLE USAGE:
%
% 
% check_WM_decay_rehearsal_effect(thisSimulation)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


num_trials_with_decayed_feature = 0;
failures_due_to_decay = 0;
failed_trials = [];

for trial = 1 : simulation.numTrials

	if any(simulation.WMdecayedFeatures{trial})
		num_trials_with_decayed_feature = num_trials_with_decayed_feature + 1;
		first_decayed_feature = min(find(simulation.WMdecayedFeatures{trial} ~= 0));
		if any(simulation.WMrehearsalFailuresPerTrial{trial}(first_decayed_feature:end) .* simulation.WMrehearsalAttemptsPerTrial{trial}(first_decayed_feature:end))
			failures_due_to_decay = failures_due_to_decay + 1;
		end
		failed_trials(end+1) = trial;
	end
end

percent_decay_trials_failed_rehearsal = failures_due_to_decay / num_trials_with_decayed_feature;
end
