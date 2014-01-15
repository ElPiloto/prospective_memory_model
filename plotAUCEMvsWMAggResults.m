function [EM_auc, WM_auc  ] = plotAUCEMvsWMAggResults( simulations)

num_simulations = numel(simulations);

numTrials = numel(simulations(1).WMpresentationStrengthsPerTrial);

EM_auc = [];
WM_auc = [];

for trial_number = 1 : numTrials

	concatenated_strengths_WM = [];
	concatenated_strengths_EM = [];
	labels_WM = [];
	labels_EM = [];

	for simulation_idx = 1 : num_simulations
		% gather EM
		concatenated_strengths_EM = [ concatenated_strengths_EM simulations(simulation_idx).EMpresentationStrengthsPerTrial{trial_number}];

		labels = zeros(size(simulations(simulation_idx).EMpresentationStrengthsPerTrial{trial_number}));
		labels(end) = 1;
		labels_EM = [labels_EM labels];

		% gather WM
		concatenated_strengths_WM = [ concatenated_strengths_WM simulations(simulation_idx).WMpresentationStrengthsPerTrial{trial_number}];

		labels = zeros(size(simulations(simulation_idx).WMpresentationStrengthsPerTrial{trial_number}));
		labels(end) = 1;
		labels_WM = [labels_WM labels];
	end

	[~,~,~,EM_auc(trial_number)] = perfcurve2(labels_EM,concatenated_strengths_EM,1);
	[~,~,~,WM_auc(trial_number)] = perfcurve2(labels_WM,concatenated_strengths_WM,1);
end

plot(EM_auc);
hold all;
plot(WM_auc);
legend({'EM AUC' 'WM AUC'});
grid on;
ylim([0.4 1.0]);
