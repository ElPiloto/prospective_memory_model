
numTrials = numel(this.WMpresentationStrengthsPerTrial);

for trial_number = 1 : numTrials
	plotREMplusTrial()
	pause(0.35)
	hold off;
end
