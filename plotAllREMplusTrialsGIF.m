filename = 'allTrials.gif';

numTrials = numel(this.WMpresentationStrengthsPerTrial);

figure(13);
for trial_number = 1 : numTrials
	plotREMplusTrial()
	title({'Blue = WM, Red = EM - Green = Rehearsal Success' 'Numbers across top indicate # decayed features' ['Trial # ' num2str(trial_number) ] });
	drawnow
	frame = getframe(13);
	hold off;
	im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
	if trial_number == 1;
		imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
	else
		imwrite(imind,cm,filename,'gif','WriteMode','append');
	end
end
