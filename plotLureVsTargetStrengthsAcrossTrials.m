
numTrials = numel(this.WMpresentationStrengthsPerTrial);
numPresentationsPerTrial = size(this.presentationTargetIndicator{1});

EM_targets = [];
EM_lures = [];
WM_targets = [];
WM_lures = [];
labels_WM = [];
labels_EM = [];
for trial_number = 1 : numTrials
	% get lure and target idxs
	lure_idcs = find(this.presentationTargetIndicator{trial_number} == 0);
	target_idcs = find(this.presentationTargetIndicator{trial_number} == 1);

	% gather EM
	this_trial_EM = log(this.EMpresentationStrengthsPerTrial{trial_number});
	EM_targets(trial_number) = mean(this_trial_EM(target_idcs));
	EM_lures(trial_number) = mean(this_trial_EM(lure_idcs));

	% gather WM
	this_trial_WM = log(this.WMpresentationStrengthsPerTrial{trial_number});
	WM_targets(trial_number) = mean(this_trial_WM(target_idcs));
	WM_lures(trial_number) = mean(this_trial_WM(lure_idcs));
end

subplot(2,1,1);
hold all;
plot(EM_targets); plot(EM_lures,'--');
plot(zeros(size(EM_targets,2),1),'k');
legend({'EM Target Probes' 'EM Lure Probes' });

subplot(2,1,2);
hold all;
plot(WM_targets); plot(WM_lures,'--');
plot(zeros(size(EM_targets,2),1),'k');
legend({'WM Target Probes' 'WM Lure Probes'});
%title({'20'  });


figure; hold all;
%bar([(EM_targets - EM_lures); (WM_targets - WM_lures)]','stacked');
width1 = 1.0;
bar(1:numTrials,[(EM_targets - EM_lures)],width1,'EdgeColor','none','FaceColor',[0.2 0.2 0.5]);
bar(1:numTrials,[(WM_targets - WM_lures)],width1/2,'EdgeColor','none','FaceColor',[0 0.7 0.7]);
legend({'EM Targets minus Lures' 'WM Targets minus Lures'},'Location','Best');
