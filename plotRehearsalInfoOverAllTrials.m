function [ avg_rehearsal_failures, wrong_context_strengths ] = plotRehearsalInfoOverAllTrials( simulation)
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


avg_rehearsal_failures = [];

plot_rehearsed_strengths = false;

% note this assumes that there is a uniform number of rehearsal attempts per trial
if any(simulation.WMrehearsalAttemptsPerTrial{1})
	numRehearsalAttemptsPerTrial = numel(find(simulation.WMrehearsalAttemptsPerTrial{1}));
	rehearsed_memory_strengths = zeros(numRehearsalAttemptsPerTrial,simulation.numTrials);
	plot_rehearsed_strengths = true;
	rehearsal_labels = cell(size(rehearsed_memory_strengths));
end

for trial_number = 1 : simulation.numTrials
	% this only draws a rehearsal as a failure if it retrived the wrong item AND we didn't reject the rehearsal
	avg_rehearsal_failures(trial_number) = any((simulation.WMrehearsalFailuresPerTrial{trial_number} > 0) .* (simulation.WMrejectedRehearsal{trial_number} == 0) );
	if plot_rehearsed_strengths
		rehearsed_probe_numbers = find(simulation.WMrehearsalAttemptsPerTrial{trial_number});
		rehearsed_memory_strengths(:,trial_number) = simulation.WMrehearsedStrengths{trial_number}(rehearsed_probe_numbers);
		rehearsal_labels(:,trial_number) = createLabelFromRehearsal(simulation,trial_number,rehearsed_probe_numbers);
    end
end

if plot_rehearsed_strengths
	%subplot(2,1,1);
	imagesc(avg_rehearsal_failures);
	% subplot(2,1,2);
	% imagesc(log(rehearsed_memory_strengths));
	grid on;
	xplaces = 1 : 1 : size(rehearsed_memory_strengths,2);
	yplaces = 1 : 1 : size(rehearsed_memory_strengths,1) ;
	yplaces = yplaces/size(rehearsed_memory_strengths,1) + 0.25;
	% jitter y
	[xla, yla ] = meshgrid(xplaces - 0.25, yplaces);
	yla(:,1:2:size(yla,2)) = yla(:,1:2:size(yla,2)) + 0.25;
	text(xla(:), yla(:), reshape(rehearsal_labels,numel(xla),1),'FontSize',10,'FontWeight','light');
	figure; 
	imagesc(log(rehearsed_memory_strengths));
else
	imagesc(avg_rehearsal_failures);
end


end


function [label_values] = createLabelFromRehearsal(simulation, trial_number, rehearsed_probe_numbers)
	% rejected color
	reject_color = '\color[rgb]{0.8 0.4 0.2}';
	not_reject_color = '\color[rgb]{0.2 0.8 0.2}';

	% REJECTED, 
	label_values = cell(numel(rehearsed_probe_numbers),1);
	for probe_idx = 1 : numel(rehearsed_probe_numbers)
		probe = rehearsed_probe_numbers(probe_idx);
		% strictly speaking we don't have to pop these values out, but it's easier this way
		rejected = simulation.WMrejectedRehearsal{trial_number}(probe);
		rightItemWrongContext = simulation.WMrehearsalRightItemWrongContext{trial_number}(probe);
		wrongItem = ~rightItemWrongContext && simulation.WMrehearsalFailuresPerTrial{trial_number}(probe);
		success = ~rightItemWrongContext && ~wrongItem;
		label = '';
		if rejected
			label = reject_color;
		else
			label = not_reject_color;
		end
		
		if rightItemWrongContext
			label = [label 'C'];
		elseif wrongItem
			label = [label 'W'];
		elseif success
			label = [label ''];
		end

		label_values{probe_idx} = label;
	end

end
