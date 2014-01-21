function [out_prof, xaxis] = profile_int( mage, X, Y, width )
% Function produces an integrated profile using a simple method to rotate
% and image and then crop it, and then sum the remainder.
%
% Usage:
%   out_prof = profile_int( mage, X, Y )
%       mage = input image
%       X = pair of x-coords
%       Y = pair of Y-coords
%       width = width of the box in pixels

dx = diff(X);
dy = diff(Y);
% Proper length of the profile
rad = sqrt( dx.^2 + dy.^2 ); 
frad = floor( rad ); % integer pixels

% Find angle with atan2
theta = atan2( dy, dx );
theta_deg = theta ./ pi .* 180;

disp( [ 'Rotating by ', num2str( theta_deg ) , ' degrees' ] )

% Find where the points are now with a rotation matrix
msize = size( mage );
% Keep in mind that there's some coordinate confunsion here.  A direct
% application of an affine transformation rotates with respect to the
% origin (1,1) at the corner of the image.  However, imrotate is rotating
% about the _center_ of the image.  So we must translate the coordinate
% frame, rotate, and then translate back

trans_back = [1 0 -msize(2)/2; 0 1 -msize(1)/2; 0 0 1];
rot_affine = [ cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1];
trans_forward = [1 0 msize(2)/2; 0 1 msize(1)/2; 0 0 1];

pair1 = [X(1); Y(1); 1];
pair2 = [X(2); Y(2); 1];

pair1prime = trans_forward*rot_affine*trans_back*pair1;
pair2prime = trans_forward*rot_affine*trans_back*pair2;

Xprime = [pair1prime(1) pair2prime(1)];
Yprime = [pair1prime(2) - width/2, pair2prime(2) + width/2];


% Rotate image
rotmage = imrotate( mage, theta_deg, 'bicubic', 'crop' );


% figure; movegui;
% imagesc( rotmage );
% rectangle( 'Position', [Xprime(1) Yprime(1) diff(Xprime) diff(Yprime)] );


% Crop image to the transformed coordinates
%        I2 = imcrop(I,RECT)
%        X2 = imcrop(X,MAP,RECT)
%  
%     RECT is a 4-element vector with the form [XMIN YMIN WIDTH HEIGHT];
%     these values are specified in spatial coordinates.
cropmage = imcrop( rotmage, [Xprime(1) Yprime(1) diff(Xprime) diff(Yprime)] );

% Ok so we integrate around y, from x1' to x2'
out_prof = mean( cropmage, 1 );
xaxis = linspace( Xprime(1), Xprime(2), numel( out_prof ) );

% figure; movegui;
% subplot(1,2,1), imagesc( cropmage );
% colorbar;
% subplot(1,2,2), plot( xaxis, out_prof );


