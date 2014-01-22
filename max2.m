function [maxval, maxpos] = max2( in_matrix )
% Function finds the position (two element array) and value of the maximal
% value of the provided matrix.

[~, x_pos] = max( max( in_matrix, [], 1 ));
[maxval, y_pos] = max( max( in_matrix, [], 2 ));

maxpos = [y_pos, x_pos];