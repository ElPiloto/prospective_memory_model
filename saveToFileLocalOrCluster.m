function [  ] = saveToFileLocalOrCluster( trial_simulation )
% [  ] = SAVETOFILELOCALORCLUSTER(trial_simulation)
% Purpose
% 
% will save simulation result 
%
% INPUT
%
% trial_simulation - should be a Trial_Simulator object, i know shitty naming convention but too bad
%
% OUTPUT
% 
% Description of outputs
%
% EXAMPLE USAGE:
%
% 
% saveToFileLocalOrCluster(myTrialSimulation)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,compName] = system('hostname');
onCluster = strmatch('node',compName);
if onCluster
	save_file = ['sim_results_' trial_simulation.tid '.mat'];
	save(fullfile(PM_task.SAVE_DIRECTORY, save_file),'trial_simulation','-v7.3');
	% we also save a barebones version
	save_file = ['sim_results_' trial_simulation.tid 'barebones.mat'];
	p_old = trial_simulation.EMpresentationProbOld;
	p_new = trial_simulation.EMpresentationProbNew;
	p_target_indicator = trial_simulation.presentationTargetIndicator;
	save(fullfile(PM_task.SAVE_DIRECTORY, save_file),'p_old','p_new','p_target_indicator','-v7.3');

else
	save_file = ['sim_results_' trial_simulation.tid '.mat'];
	save(save_file,'trial_simulation','-v7.3');
	% we also save a barebones version
	save_file = ['sim_results_' trial_simulation.tid 'barebones.mat'];
	p_old = trial_simulation.EMpresentationProbOld;
	p_new = trial_simulation.EMpresentationProbNew;
	p_target_indicator = trial_simulation.presentationTargetIndicator;
	save(save_file,'p_old','p_new','p_target_indicator','-v7.3');

end



end

% catch err
% 	disp(err.message());
% 	err.stack(1)
% end
%exit
