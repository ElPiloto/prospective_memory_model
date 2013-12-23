
numTrials = numel(this.WMpresentationStrengthsPerTrial);

EM_auc = [];
WM_auc = [];
concatenated_strengths_WM = [];
concatenated_strengths_EM = [];
labels_WM = [];
labels_EM = [];
for trial_number = 1 : numTrials
	% gather EM
	this_trial_EM = [this.EMpastTargetsStrengthsPerTrial{trial_number} this.EMpastLureStrengthsPerTrial{trial_number}] ;
	concatenated_strengths_EM = [ concatenated_strengths_EM this_trial_EM];
	labels = zeros(size(this_trial_EM));
	labels(1:numel(this.EMpastTargetsStrengthsPerTrial{trial_number})) = 1;
	labels_EM = [labels_EM labels];
	[~,~,~,EM_auc(trial_number)] = perfcurve2(labels_EM,concatenated_strengths_EM,1);

	% gather WM
	this_trial_WM = [this.WMpastTargetsStrengthsPerTrial{trial_number} this.WMpastLureStrengthsPerTrial{trial_number}] ;
	concatenated_strengths_WM = [ concatenated_strengths_WM this_trial_WM];
	labels = zeros(size(this_trial_WM));
	labels(1:numel(this.WMpastTargetsStrengthsPerTrial{trial_number})) = 1;
	labels_WM = [labels_WM labels];
	[~,~,~,WM_auc(trial_number)] = perfcurve2(labels_WM,concatenated_strengths_WM,1);

end

plot(EM_auc);
hold all;
plot(WM_auc);
legend({'EM AUC' 'WM AUC'});
