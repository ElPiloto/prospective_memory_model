function [ avg_num_features_decayed ] = get_mean_num_features_decayed( simulation )
% [ avg_num_features_decayed ] = GET_MEAN_NUM_FEATURES_DECAYED(simulation)
% Purpose
% 
% This will go through the results of a Trial_Simulation object and tell you on average how many features were decayed on each trial
%
% INPUT
%
% simulation - Trial_Simulation objects
%
% OUTPUT
% 
% avg_num_features_decayed - self-explanatory
%
% EXAMPLE USAGE:
%
% 
% get_mean_num_features_decayed(this)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

concatenated_decayed = cell2mat(simulation.WMdecayedFeatures');
avg_num_features_decayed = mean(concatenated_decayed);

% here we also look at the average number of features decayed when we perform a rehearsal
num_features_decayed = [];
% for trial_idx = 1 : numel(this.WMdecayedFeatures)
% 	%tmp = simulation.
% end


end
