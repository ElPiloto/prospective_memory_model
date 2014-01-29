function [  ] = plotMemStrengthRehearsals( simulation )
% [  ] = PLOTMEMSTRENGTHREHEARSALS(simulation)
% Purpose
% 
% This function will draw a histogram of the following rehearsal types:
%
% INPUT
%
% simulation - Trial_simulation result
%
% OUTPUT
% 
% EXAMPLE USAGE:
% 
% plotMemStrengthRehearsals()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ rightItemWrongContext, wrongItem, rejected, success, falseRejection ] = getAvgRehearsalStrength(simulation);

histTwoDataSets(log(rightItemWrongContext), log(wrongItem), -1, 'Right Item Wrong Context', 'Wrong Item');
xlabel('Log Mem Strength');

end
