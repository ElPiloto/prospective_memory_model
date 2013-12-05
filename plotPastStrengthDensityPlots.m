function [canvas_targets canvas_lures min_x max_x min_y max_y ] = plotPastStrengthDensityPlots( trial_simulator , log_scale)
% [  ] = PLOTPASTSTRENGTHDENSITYPLOTS(trial_simulator)
% Purpose
% 
% 
%
% INPUT
%
% trial_simulator - a Trial_Simulator object resulting from running Trial_Si
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% plotPastStrengthDensityPlots(trial_simulator)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
	log_scale = true;
end

if log_scale
	wm_targets = log([trial_simulator.WMpastTargetsStrengthsPerTrial{1:end}]);
	em_targets = log([trial_simulator.EMpastTargetsStrengthsPerTrial{1:end}]);
	em_lures = log([trial_simulator.EMpastLureStrengthsPerTrial{1:end}]);
	wm_lures = log([trial_simulator.WMpastLureStrengthsPerTrial{1:end}]);
else
	wm_targets = [trial_simulator.WMpastTargetsStrengthsPerTrial{1:end}];
	em_targets = [trial_simulator.EMpastTargetsStrengthsPerTrial{1:end}];
	em_lures = [trial_simulator.EMpastLureStrengthsPerTrial{1:end}];
	wm_lures = [trial_simulator.WMpastLureStrengthsPerTrial{1:end}];
end

max_x = max(max(wm_targets), max(wm_lures));
max_y = max(max(em_targets), max(em_lures));
min_x = min(min(wm_targets), min(wm_lures));
min_y = min(min(em_targets), min(em_lures));

axis_limits = [min_x max_x min_y max_y];
figure(7); subplot(1,2,1);
set(gcf,'position',get(0,'screensize'));
[h_targets canvas_targets] = cloudPlot(wm_targets,em_targets,axis_limits);
xlabel('WM'); ylabel('EM'); title('Targets');

subplot(1,2,2);
[h_lures canvas_lures] = cloudPlot(wm_lures,em_lures,axis_limits);
xlabel('WM'); ylabel('EM'); title('Lures');
end
