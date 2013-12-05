function [  ] = plotContextDriftAcrossTrials( this )
% [  ] = PLOTCONTEXTDRIFTACROSSTRIALS(this)
% Purpose
% 
% 
%
% INPUT
%
% this - Trial_simulator results
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% plotContextDriftAcrossTrials(this)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pairwiseContextDifference = zeros(this.numTrials-1,1);
% plot successive difference
for trial = 2 : this.numTrials
	pairwiseContextDifference(trial-1) = sum(this.contextVectors(:,trial-1) ~= this.contextVectors(:,trial));
end

figure(9);
plot(pairwiseContextDifference);

% plot difference between all 
distanceFromFirstContext = zeros(this.numTrials-1,1);
% plot successive difference
for trial = 2 : this.numTrials
	distanceFromFirstContext(trial-1) = sum(this.contextVectors(:,trial) ~= this.contextVectors(:,1));
end

hold all;
plot(distanceFromFirstContext);
legend({'current vs. previous' 'current vs. first'});
xlabel('Trial Number');
ylabel('# Mismatched Features');
title('Change in context vectors across trials');

end
