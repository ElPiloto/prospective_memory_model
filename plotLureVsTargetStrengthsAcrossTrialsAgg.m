function [EM_targets, EM_lures, WM_targets, WM_lures] = plotLureVsTargetStrengthsAcrossTrials(simulations)
% [  ] = PLOTLUREVSTARGETSTRENGTHSACROSSTRIALS(input_args)
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
% plotLureVsTargetStrengthsAcrossTrials(Example inputs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_simulations = numel(simulations);

numTrials = numel(simulations(1).WMpresentationStrengthsPerTrial);
numPresentationsPerTrial = size(simulations(1).presentationTargetIndicator{1});

EM_targets = NaN(num_simulations,numTrials);
EM_lures = NaN(num_simulations,numTrials);
WM_targets = NaN(num_simulations,numTrials);
WM_lures = NaN(num_simulations,numTrials);
labels_WM = [];
labels_EM = [];

for simulation_idx = 1 : num_simulations

	for trial_number = 1 : numTrials
		% get lure and target idxs
		lure_idcs = find(simulations(simulation_idx).presentationTargetIndicator{trial_number} == 0);
		target_idcs = find(simulations(simulation_idx).presentationTargetIndicator{trial_number} == 1);

		% gather EM
		this_trial_EM = log(simulations(simulation_idx).EMpresentationStrengthsPerTrial{trial_number});
		EM_targets(simulation_idx,trial_number) = mean(this_trial_EM(target_idcs));
		EM_lures(simulation_idx,trial_number) = mean(this_trial_EM(lure_idcs));

		% gather WM
		this_trial_WM = log(simulations(simulation_idx).WMpresentationStrengthsPerTrial{trial_number});
		WM_targets(simulation_idx,trial_number) = mean(this_trial_WM(target_idcs));
		WM_lures(simulation_idx,trial_number) = mean(this_trial_WM(lure_idcs));
	end
end

subplot(2,1,1);
hold all;
plot(mean(EM_targets,1)); plot(mean(EM_lures,1),'--');
plot(zeros(size(EM_targets,2),1),'k');
legend({'EM Target Probes' 'EM Lure Probes' });

subplot(2,1,2);
hold all;
plot(mean(WM_targets,1)); plot(mean(WM_lures,1),'--');
plot(zeros(size(EM_targets,2),1),'k');
legend({'WM Target Probes' 'WM Lure Probes'});


figure; hold all;
%bar([(EM_targets - EM_lures); (WM_targets - WM_lures)]','stacked');
width1 = 1.0;
bar(1:numTrials,[(mean(EM_targets - EM_lures,1))],width1,'EdgeColor','none','FaceColor',[0.2 0.2 0.5]);
bar(1:numTrials,[(mean(WM_targets - WM_lures,1))],width1/2,'EdgeColor','none','FaceColor',[0 0.7 0.7]);
legend({'EM Targets minus Lures' 'WM Targets minus Lures'},'Location','Best');

end
