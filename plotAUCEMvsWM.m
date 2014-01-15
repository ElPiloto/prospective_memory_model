function [ EM_auc, WM_auc ] = plotAUCEMvsWM( simulation )
% [ EM_auc, WM_auc ] = PLOTAUCEMVSWM(simulation)
% Purpose
% 
% Will plot the AUC from an receiver operating characteristic analysis
% for both EM and WM memory systems across each trial.
%
% INPUT
%
% simulation - single Trial_Simulator object
%
% OUTPUT
% 
% the AUC for both memory types calculated for each trial
%
% EXAMPLE USAGE:
%
% myTrialSim.ILL_SIM_YOU_LATER();
% plotAUCEMvsWM(myTrialSim)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numTrials = numel(simulation.WMpresentationStrengthsPerTrial);

EM_auc = [];
WM_auc = [];
concatenated_strengths_WM = [];
concatenated_strengths_EM = [];
labels_WM = []; labels_EM = [];
for trial_number = 1 : numTrials
	% gather EM
	%simulation_trial_EM = [simulation.EMpastTargetsStrengthsPerTrial{trial_number} simulation.EMpastLureStrengthsPerTrial{trial_number}] ;
	%concatenated_strengths_EM = [ concatenated_strengths_EM simulation_trial_EM];
	concatenated_strengths_EM = [ concatenated_strengths_EM simulation.EMpresentationStrengthsPerTrial{trial_number}];
	labels = zeros(size(simulation.EMpresentationStrengthsPerTrial{trial_number}));
	%labels(1:numel(simulation.EMpastTargetsStrengthsPerTrial{trial_number})) = 1;
	labels(end) = 1;
	labels_EM = [labels_EM labels];
	[~,~,~,EM_auc(trial_number)] = perfcurve2(labels_EM,concatenated_strengths_EM,1);

	% gather WM
	%simulation_trial_WM = [simulation.WMpastTargetsStrengthsPerTrial{trial_number} simulation.WMpastLureStrengthsPerTrial{trial_number}] ;
	%concatenated_strengths_WM = [ concatenated_strengths_WM simulation_trial_WM];
	concatenated_strengths_WM = [ concatenated_strengths_WM simulation.WMpresentationStrengthsPerTrial{trial_number}];
	labels = zeros(size(simulation.WMpresentationStrengthsPerTrial{trial_number}));
	%labels(1:numel(simulation.WMpastTargetsStrengthsPerTrial{trial_number})) = 1;
	labels(end) = 1;
	labels_WM = [labels_WM labels];
	[~,~,~,WM_auc(trial_number)] = perfcurve2(labels_WM,concatenated_strengths_WM,1);

end

figure;
plot(EM_auc);
hold all;
plot(WM_auc);
legend({'EM AUC' 'WM AUC'});

end
