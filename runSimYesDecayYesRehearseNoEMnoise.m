%try
	simulation = Trial_Simulator();
	simulation = simulation.ILL_SIM_YOU_LATER();

	saveToFileLocalOrCluster(simulation);

	if ~exist('shouldExitIfOnCluster','var') || shouldExitIfOnCluster
		exitIfOnCluster();
	end
	% catch err
% 	disp(err.message());
% 	err.stack(1)
% end
%exit
