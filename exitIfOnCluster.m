
[~,compName] = system('hostname');
onCluster = strmatch('node',compName);
if onCluster
	exit
end

