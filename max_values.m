function [ Y I ] = max_values( X )
% [ Y I ] = MAX_VALUES(X)
% Purpose
% 
% This function returns the max value in an array and the corresponding index.  UNLIKE the standard
% Matlab max function, this returns multiple values in the event there is a tie for the max value.
%
% INPUT
%
% X - a numeric array
%
% OUTPUT
% 
% Y - contains the max value in the input array X
% I - contains the index (or indices) of the max value
%
% EXAMPLE USAGE:
%
% 
% [Y I ] = max_values([1 5 5 2 4 5])
%    y = 5
%    i = [2 3 6]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Y I] = max(X);

I = find(X == Y);

end
