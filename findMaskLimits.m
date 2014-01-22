function [limits] = findMaskLimits( mask )
% Function finds the limits of a binary mask (generally so the image can be
% cropped).  
%   mask must be 2-D binary image (of 1.0s and 0.0s)  
%   limits = [x1 y1 x2 y2]

maskedgex = sum( mask, 2 ) > 0;
maskedgey = sum( mask, 1 ) > 0;

x1 = find( maskedgex, 1, 'first' );
x2 = find( maskedgex, 1, 'last' );
y1 = find( maskedgey, 1, 'first' );
y2 = find( maskedgey, 1, 'last' );

limits = [x1 y1 x2 y2];