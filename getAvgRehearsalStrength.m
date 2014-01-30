function [ rightItemWrongContext, wrongItem, rejected, success, falseRejection ] = getAvgRehearsalStrength( simulation )
% [ rightItemWrongContext, wrongItem, rejected ] = GETAVGREHEARSALSTRENGTH(simulation)
% Purpose
% 
% This function will look at each trial's rehearsal attempts and grab the memory strength for the
% highest matching EM trace for the rehearsal attempt, regardless of whether it succeeded or not
% and categorgize it accordingly into one of the three aggregate classes.
%
% INPUT
%
% OUTPUT
%
% rightItemWrongContext - Any rehearsed items that matched the current target, but was from 
% a previous context
%
% wrongitem - Any rehearsed item from a different item altogether
%
% rejected - Any rehearsed item that was subsequently rejected
%
% success - Rehearsed item that retrieved the right trace and wasn't rejected
%
% EXAMPLE USAGE:
%
% 
% getAvgRehearsalStrength(Example inputs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rightItemWrongContext = [];
wrongItem = [];
rejected = [];
success = [];
falseRejection = [];

for trial_number = 1 : simulation.numTrials
	rehearsed_probe_numbers = find(simulation.WMrehearsalAttemptsPerTrial{trial_number});

	for probe_idx = 1 : numel(rehearsed_probe_numbers)
		probe = rehearsed_probe_numbers(probe_idx);

		rejectedB = simulation.WMrejectedRehearsal{trial_number}(probe);
		rightItemWrongContextB = simulation.WMrehearsalRightItemWrongContext{trial_number}(probe);
		wrongItemB = ~rightItemWrongContextB && simulation.WMdidRehearsalMatchDifTrace{trial_number}(probe);
		successB = ~rightItemWrongContextB && ~wrongItemB && ~rejectedB;
		falseRejectionsB = rejectedB && simulation.WMdidRehearsalMatchDifTrace{trial_number}(probe);

		rehearsedStrength = simulation.WMrehearsedStrengths{trial_number}(probe);

		if rejectedB
			rejected(end+1) = rehearsedStrength;
		end
		if rightItemWrongContextB
			rightItemWrongContext(end+1) = rehearsedStrength;
		end
		if wrongItemB
			wrongItem(end+1) = rehearsedStrength;
		end
		if successB
			success(end+1) = rehearsedStrength;
		end
		if falseRejectionsB
			falseRejection(end+1) = rehearsedStrength;
		end

	end

end

end



