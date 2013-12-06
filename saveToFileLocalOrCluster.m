function [  ] = saveToFileLocalOrCluster( this )
% [  ] = SAVETOFILELOCALORCLUSTER(this)
% Purpose
% 
% will save simulation result 
%
% INPUT
%
% this - should be a Trial_Simulator object, i know shitty naming convention but too bad
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
	save_file = ['EM_sim_results_' this.tid '.mat'];
	save(['/fastscratch/lpiloto/prosp_mem/' save_file],'this','-v7.3');
	% we also save a barebones version
	save_file = ['EM_sim_results_' this.tid 'barebones.mat'];
	p_old = this.EMpresentationProbOld;
	p_new = this.EMpresentationProbNew;
	p_target_indicator = this.presentationTargetIndicator;
	save(['/fastscratch/lpiloto/prosp_mem/' save_file],'p_old','p_new','p_target_indicator','-v7.3');

else
	save_file = ['EM_sim_results_' this.tid '.mat'];
	save(save_file,'this','-v7.3');
	% we also save a barebones version
	save_file = ['EM_sim_results_' this.tid 'barebones.mat'];
	p_old = this.EMpresentationProbOld;
	p_new = this.EMpresentationProbNew;
	p_target_indicator = this.presentationTargetIndicator;
	save(save_file,'p_old','p_new','p_target_indicator','-v7.3');

end



end

% catch err
% 	disp(err.message());
% 	err.stack(1)
% end
%exit
