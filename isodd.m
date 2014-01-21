function [output] = isodd( input )
% Function computes whether an integer is odd

output = ~(mod( input, 2 ) == 0);