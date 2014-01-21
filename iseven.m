function [output] = iseven( input )
% Function computes whether an integer is even

output = mod( input, 2 ) == 0;