function [ targetJudgment responseCorrect normalized_responses labels ] = generateDecisionsAndPlot( this )
% [  ] = GENERATEDECISIONSANDPLOT(this)
% Purpose
% 
% 
%
% INPUT
%
% 
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% generateDecisionsAndPlot()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

targetJudgment = zeros(this.numTrials,numel(this.WMpresentationStrengthsPerTrial{1}));
responseCorrect = zeros(this.numTrials,numel(this.WMpresentationStrengthsPerTrial{1}));

totalFalsePositives = [0];
totalFalseNegatives = [0];
totalTruePositives = [0];
totalTrueNegatives = [0];

% we start off at trial 2 because we have no history on trial 1
for trial_idx = 2 : this.numTrials
	numProbes = numel(this.WMpresentationStrengthsPerTrial{trial_idx});

	% get histogram values
	wm_targets = log([this.WMpastTargetsStrengthsPerTrial{1:trial_idx-1}]);
	em_targets = log([this.EMpastTargetsStrengthsPerTrial{1:trial_idx-1}]);
	em_lures = log([this.EMpastLureStrengthsPerTrial{1:trial_idx-1}]);
	wm_lures = log([this.WMpastLureStrengthsPerTrial{1:trial_idx-1}]);

	max_x = max(max(wm_targets), max(wm_lures));
	max_y = max(max(em_targets), max(em_lures));
	min_x = min(min(wm_targets), min(wm_lures));
	min_y = min(min(em_targets), min(em_lures));
	edges = {[ min_x : (max_x - min_x)/5 : max_x] [ min_y : (max_y - min_y)/5 : max_y]};
	[N_targets, C_targets] = hist3([wm_targets' em_targets'], 'EDGES', edges);
	[N_lures, C_lures] = hist3([wm_lures' em_lures'], 'EDGES', edges);

	% normalize histograms
	N_targets = N_targets / sum(sum(N_targets));
	N_lures = N_lures / sum(sum(N_lures));


	for probe_idx = 1 : numProbes
		wm = this.WMpresentationStrengthsPerTrial{trial_idx}(probe_idx);
		em = this.EMpresentationStrengthsPerTrial{trial_idx}(probe_idx);

		% finally, look up values - we use the bin centers from the targets, btu it doesn't matter - they should be the same
		[xInd, yInd] = lookup(wm,em, C_targets);

		% target judgment
		if N_targets(xInd,yInd) > N_lures(xInd,yInd)
			targetJudgment(trial_idx,probe_idx) = 1;
		elseif N_targets(xInd,yInd) == 0 && N_lures(xInd,yInd) == 0
			targetJudgment(trial_idx,probe_idx) = NaN;
			% % randomly decide if nan
			% if rand() < 0.5
			% 	targetJudgment(trial_idx,probe_idx) = 1;
			% else
			% 	targetJudgment(trial_idx,probe_idx) = 0;
			% end
		else
			targetJudgment(trial_idx,probe_idx) = 0;
		end

		% here we take advantage of the fact that we nly test probes at the end of the trial:
		% specifically, 
		if isnan(targetJudgment(trial_idx,probe_idx))
			responseCorrect(trial_idx,probe_idx) = NaN;
		elseif targetJudgment(trial_idx,probe_idx) == (probe_idx == numProbes)
			responseCorrect(trial_idx,probe_idx) = 1;
		else
			responseCorrect(trial_idx,probe_idx) = -1;
		end

		if probe_idx == numProbes % we're on a target trial
			if responseCorrect(trial_idx, probe_idx) == 1
				totalTruePositives(end+1) = totalTruePositives(end) + 1;
				totalTrueNegatives(end+1) = totalTrueNegatives(end);
				totalFalseNegatives(end+1) = totalFalseNegatives(end);
				totalFalsePositives(end+1) = totalFalsePositives(end);
            elseif responseCorrect(trial_idx, probe_idx) == 1
				totalTruePositives(end+1) = totalTruePositives(end) ;
				totalTrueNegatives(end+1) = totalTrueNegatives(end);
				totalFalseNegatives(end+1) = totalFalseNegatives(end) + 1;
				totalFalsePositives(end+1) = totalFalsePositives(end);
			end
		else
			if responseCorrect(trial_idx, probe_idx) == 1 
				totalTruePositives(end+1) = totalTruePositives(end) ;
				totalTrueNegatives(end+1) = totalTrueNegatives(end) + 1;
				totalFalseNegatives(end+1) = totalFalseNegatives(end);
				totalFalsePositives(end+1) = totalFalsePositives(end);
            elseif responseCorrect(trial_idx, probe_idx) == 1
				totalTruePositives(end+1) = totalTruePositives(end) ;
				totalTrueNegatives(end+1) = totalTrueNegatives(end);
				totalFalseNegatives(end+1) = totalFalseNegatives(end);
				totalFalsePositives(end+1) = totalFalsePositives(end) + 1;
			end

		end
	end

end

% manipulate the correct
normalized_responses = [totalTruePositives' totalTrueNegatives' totalFalsePositives' totalFalseNegatives']';
normalized_responses = normalized_responses ./ repmat(sum(normalized_responses,1),4,1);
labels = {'True Positives' 'True Negatives' 'False Positives' 'False Negatives'};

% now we'll actually plot these results
figure(10);
subplot(1,2,1);
continuous = reshape(responseCorrect,[10000 1])';
bar(continuous,'LineWidth',0.5);
xlim([0 numel(continuous)]);
set(gca,'YTick',[-1 1]);
set(gca,'YTickLabel',{'Incorrect' 'Correct'});
xlabel('Probe #');
prcnt_correct = numel(find(continuous == 1)) / numel(continuous);
title(['Total Accuracy = ' num2str(prcnt_correct * 100) '%']);

subplot(1,2,2);
hold all;
bar(1:4,normalized_responses(:,end));
set(gca,'XTickLabels',labels);
set(gca,'XTick',1:4);
title('Percent responses over all trials');

end


function [ indX, indY] = lookup(x_value, y_value, centers)

% get bin centers in X
[~,indX] = min(abs(centers{1} - x_value));
[~,indY] = min(abs(centers{2} - y_value));

end
