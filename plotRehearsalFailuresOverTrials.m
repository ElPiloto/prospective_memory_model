function [ avg_rehearsal_failures ] = plotRehearsalFailuresOverTrials( this )
% [  ] = PLOTREHEARSALFAILURESOVERTRIALS(this)
% Purpose
% 
% this - a trial simulator object
%
% INPUT
%
% this - a trial simulator object 
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% plotRehearsalFailuresOverTrials(this)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

avg_rehearsal_failures = [];

for trial_number = 1 : this.numTrials
	avg_rehearsal_failures(trial_number) = any(this.WMrehearsalFailuresPerTrial{trial_number} > 0 );
end

%figure(8);
plot(smooth(avg_rehearsal_failures,floor(this.numTrials * 0.2)));
xlabel('Trial Number');
ylabel('% Failures In Trials');
title('How often rehearsal attempt retrieved different item than WM contents');


end
