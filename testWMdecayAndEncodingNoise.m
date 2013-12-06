% first we generate the simulation settings the way we want - just to recycle code
PM_task.generateSimulationTargetsAndLures(100,100,1);
% to run locally, we fake the env variable assigned to indicate which job number on the cluster
setenv('SGE_TASK_ID','1');
simulation = Trial_Simulator();
simulation.turnOffWMdecay = true;

% remove WM decay
% simulation.REMsim.probFeatureDecayWMTrace = 0;
% remove rehearsal 
% simulation.REMsim.rehearsalFreqWM = Inf;

% this makes it so that we're always comparing the WM trace (as it was initially encoded - no decay, no retrieval of an EM trace)
simulation = simulation.ILL_SIM_YOU_LATER();

saveToFileLocalOrCluster(simulation);
