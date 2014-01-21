function [minval, minpos] = min2( in_matrix )
% Function finds the position (two element array) and value of the minimal
% value of the provided matrix.

[minval, x_pos] = min( min( in_matrix, [], 1 ));
[minval, y_pos] = min( min( in_matrix, [], 2 ));

minpos = [y_pos, x_pos];