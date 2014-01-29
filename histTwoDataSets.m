function [  ] = histTwoDataSets( data1, data2, plot_cum_dist,  label1, label2, figTitle)
% [  ] = HISTTWODATASETS(data1, data2)
% Purpose
% 
% This function will show two histograms on a single graph
%
% INPUT
%
% data 1 - data to histogram
% data 2 - data to histogram
% plot_cum_dist - (optional)  overlay cumulative distributions as well (1), no overlay (0 - default value)
% 							(-1) plots as P(X >= x) instead of the default cdf P(x <= x)
% label1 - (optional) legend label
% label2 - (optional) legend label
% figTitle - (optional) only available if you specify the preceding labels
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% histTwoDataSets(a,b)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shouldPlotCdf = 0;
if nargin >= 3
	shouldPlotCdf = plot_cum_dist;
end

figure;
if shouldPlotCdf ~= 0
	subplot(2,1,1);
end
hist(data1);
hold on;
%//make data1 red
%//get the handle of the bars in a histogram
h = findobj(gca,'Type','patch');
%//color of the bar is red and the color of the border
%// of the bar is white!
set(h,'FaceColor','g','EdgeColor','w');
%//data 2 use default color!
hist(data2);
h = findobj(gca,'Type','patch');
%//color of the bar is red and the color of the border
alpha(h(1),0.7);

if nargin >= 5
	legend({label1 label2});
end

if shouldPlotCdf == -1

	subplot(2,1,2);
	[n1 x1] = hist(data1);
	[n2 x2] = hist(data2);
	%scaling = max(max(n1),max(n2));
	scaling = 1;
	n1 = (sum(n1)-cumsum(n1))/sum(n1);
	n2 = (sum(n2)-cumsum(n2))/sum(n2);
	n1 = [1 n1(2:end) ];
	n2 = [1 n2(2:end) ];
	plot(x1,scaling*n1,'g-x');
	hold all;
	plot(x2,scaling*n2,'b-x');


elseif shouldPlotCdf == 1;
	subplot(2,1,2);
	[n1 x1] = hist(data1);
	[n2 x2] = hist(data2);
	scaling = max(max(n1),max(n2));
	plot(x1,scaling*(cumsum(n1)/sum(n1)));
	plot(x2,scaling*(cumsum(n2)/sum(n2)));

end

if nargin >= 5
	if shouldPlotCdf == 1
		legend({'CDF' 'CDF'});
	elseif shouldPlotCdf == -1
		legend({'P(x>=X)' 'P(x>=X)'});
	end
end

if nargin == 6
	title(figTitle);
end

end
