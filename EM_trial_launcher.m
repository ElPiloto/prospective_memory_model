%try
	EM_simulation = Trial_Simulator();
	EM_simulation = EM_simulation.ILL_SIM_YOU_LATER();

	saveToFileLocalOrCluster(simulation);
	exitIfOnCluster();
	% catch err
% 	disp(err.message());
% 	err.stack(1)
% end
%exit
