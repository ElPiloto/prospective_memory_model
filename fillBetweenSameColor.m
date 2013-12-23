function[] = fillBetweenSameColor(x,y1,y2,color,a)

fill([x fliplr(x)], [y1 fliplr(y2)], color, 'EdgeColor', color);

if exist('a','var')
    alpha(a);
end
