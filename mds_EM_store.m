function [  ] = mds_EM_store( simulation )
% [  ] = MDS_EM_STORE(simulation)
% Purpose
% 
% This will plot a 2d scatter plot of distances between EM memory traces for a given simulation result
%
% INPUT
%
% simulation - Trial Simulator object
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% mds_EM_store()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

D = pdist(simulation.REMsim.EMStore');
[Y,eigvals] = cmdscale(D);
plot(Y(:,1),Y(:,2),'.');

end
