prospective_memory_model
========================


In general, this code was designed for two use cases:
1. Running a single simulation on your machine (or on rondo)
2. Running multiple simulations on rondo

The general process of running a simulation is this:

1. Modify any memory systems parameter values in `REMplusWM.m` (how many context features, how many item features, rehearsal frequency for WM, etc).

2. Set prospective memory simulation values:
  -how many trials
  -how many unique items
  -how many simulations to run
  -how many probe presentations per trial.
  
  Example: for 500 trials, 5 unique items, 1 simulation, and 5 probes per trial.
  `PM_task.generateSimulationTargetsAndLures(500, 5, 1, 5);`
  
  Note: If you're running on rondo cluster you can increase the number of simulations.

3. Decide which type of simulation you want to run by choosing from the runSim*.m class of scripts. They have pretty self-explanatory names: `runSimYesDecayYesRehearseNoEMnoise.m`

4. Actually launch the simulation:
  `PM_task.launchSimulationsAfterGeneratingLocalOrCluster('runSimYesDecayYesRehearseNoEMnoise')` - this will run the script specified either on your local machine, or submit a bunch of jobs to run if you're on the rondo cluster.  The results will be saved either in the current folder or to a directory accessible to the cluster if you're on the cluster in a file called `sim_results_#.mat` where the # indicates which simulation number it is.
  
  **If you're going to run this on rondo, make sure you modify the save path in** `PM_task.m` -  otherwise it will save to the directory I am currently using.  
  **Before launching the simulations with a particular script such as `runSimYesDecayYesRehearseNoEMnoise.m`, pop it open in an editor and check the REMplusWM settings it sets - the settings there override any changes you might have made to REMplusWM.m, doing this will ensure you don't get seemingly anomalous behavior that's due to settings being overridden.**

5. Load the `sim_results_#.mat` (will load variable called `simulation`) and analyze the results using some of the scripts provided such as `plotAUCEMvsWM(simulation)`.  Additionally, if you run multiple simulations, you can call `aggregate_sim_results_from_cluster` which produces a variable `aggResults` and subsequently analyze this data with `plotAUCEMvsWMAggResults(aggResults)` Other scripts also have this 'AggResults' form which produce the same analysis for the aggregated simulation results.

Example Running Multiple Simulations (Assuming You're Logged Into Rondo)
------------------------------------
-Generate high PI simulations: `PM_task.generateSimulationTargetsAndLures(500, 5, 200, 5);`  
-Launch the simulations: `PM_task.launchSimulationsAfterGeneratingLocalOrCluster('runSimYesDecayYesRehearseNoEMnoise')`  
-Once all jobs are done (can type `qstat` or similar cluster commands to check jobs running): open up matlab on the cluster again and call `aggregate_sim_results_from_cluster`  
-Analyze results `plotAUCEMvsWMAggResults(aggResults)` or `plotRehearsalFailuresOverTrialsAgg(aggResults)` and save figures of interest  
-Generate low PI simulations: `PM_task.generateSimulationTargetsAndLures(500, 500, 200, 5);`  
-Rinse and repeat  
