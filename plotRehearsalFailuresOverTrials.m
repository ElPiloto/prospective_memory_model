function [ avg_rehearsal_failures ] = plotRehearsalFailuresOverTrials( simulation, smooth_size)
% [  ] = PLOTREHEARSALFAILURESOVERTRIALS(simulation)
% Purpose
% 
% This function expects either a Trial_Simulator object or a struct returned from
% aggregate_sim_results_from_cluster_and_collapse - in both cases, you only 
% plot the results from a single simulation (in the latter case, multiple simulations
% have been squashed down to make a single avg simulation)
%
%
% INPUT
%
% simulation - a trial simulator object 
% smooth_size - can be either empty or 0(no smoothing), a positive integer for smoothing, or 'auto'
% 				to specify smoothing with window = 20% of number of trials
%
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% plotRehearsalFailuresOverTrials(simulation)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
	smooth_size = 0;
end

avg_rehearsal_failures = [];

for trial_number = 1 : simulation.numTrials
	avg_rehearsal_failures(trial_number) = any(simulation.WMdidRehearsalMatchDifTrace{trial_number} > 0 );

	if any(simulation.WMrejectedRehearsal{trial_number})
		avg_rehearsal_failures(trial_number) = 0.5;
	end

end

%figure(8);
if smooth_size == 0
	%plot(avg_rehearsal_failures);
	imagesc(avg_rehearsal_failures);
	ylim([0 1]);
else
	if isstr(smooth_size)
		plot(smooth(avg_rehearsal_failures,floor(simulation.numTrials * 0.2)));
	elseif isnumeric(smooth_size) && smooth_size > 0
		plot(smooth(avg_rehearsal_failures,smooth_size));
	end
end
xlabel('Trial Number');
ylabel('% Failures In Trials');
title('How often rehearsal retrieved different trace than WM trace');


end
