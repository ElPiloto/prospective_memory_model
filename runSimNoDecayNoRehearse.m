simulation = Trial_Simulator();
simulation.turnOffWMdecay = true;
simtulation.turnOffWMrehearsal = true;

% this makes it so that we're always comparing the WM trace (as it was initially encoded - no decay, no retrieval of an EM trace)
simulation = simulation.ILL_SIM_YOU_LATER();

saveToFileLocalOrCluster(simulation);

