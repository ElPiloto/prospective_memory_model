try
	EM_simulation = EM_trial_simulator();
	EM_simulation = EM_simulation.ILL_SIM_YOU_LATER();
catch err
	disp(err.message());
	err.stack(1)
end
%exit
