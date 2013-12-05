%function [  ] = plotREMplusTrial(this, trial_number )
% [  ] = PLOTREMPLUSTRIAL(trial_number)
% Purpose
% 
% Description of function here
%
% INPUT
%
% Description of inputs
%
% OUTPUT
% 
% Description of outputs
%
% EXAMPLE USAGE:
%
% 
% plotREMplusTrial(Example inputs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

concatenatedResults = [this.WMpresentationStrengthsPerTrial{trial_number}; this.EMpresentationStrengthsPerTrial{trial_number}];
bar(log(concatenatedResults'));

numPresentations = size(concatenatedResults,2);
xlim([0.5 numPresentations+0.5]);
ylimits = ylim;
y_min = ylimits(1);
y_max = ylimits(2);

for presentation_idx = 1 : numPresentations
	if this.WMrehearsalAttemptsPerTrial{trial_number}(presentation_idx)
		% green indicates we attempted a rehearsal and got the same one back
		color = [0 1 0];

		if this.WMrehearsalFailuresPerTrial{trial_number}(presentation_idx)
			% red indicates we attempted a rehearsal and got a dif. item back
			color = [1 0 0];
		end
		vertices = [ presentation_idx-0.5 y_min 0; presentation_idx+0.5 y_min 0; presentation_idx+0.5 y_max 0 ; presentation_idx-0.5 y_max 0];
		patch('Vertices',vertices,'Faces',[1 2 3 4],'FaceColor',color);
	end
	text(presentation_idx,y_max*4/5,num2str(this.WMdecayedFeatures{trial_number}(presentation_idx)));
end
hold all;
bar(log(concatenatedResults'));
xlim([0.5 numPresentations+0.5]);
title({'Blue = WM, Red = EM - Green = Rehearsal Success' 'Numbers across top indicate # decayed features' ['Trial # ' num2str(trial_number) ] });


%end

