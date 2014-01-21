function [unrotated] = inv_rotmean( rotated )
% Takes a 1-D profile and rotates it about the first element to generate a
% 2-D pattern.

psize = length( rotated ); % length of profile

N = 2*floor(psize/sqrt(2)); % length of 2-D image

[xmesh, ymesh] = meshgrid( -(N/2):N/2 - 1, -(N/2):N/2 - 1 );
rad_mesh = sqrt( xmesh.^2 + ymesh.^2 );
rad_mesh = reshape( rad_mesh, N.^2, 1); % collapse to 1-D to pick indices

floor_mod = mod(rad_mesh,1);
floor_mesh = floor( rad_mesh ); 
floor_mesh = floor_mesh + ( floor_mesh == 0 ); % MATLAB indices start at one, eliminate the zero

unrotated = rotated( floor_mesh ) .* floor_mod + rotated( floor_mesh+1).*(1-floor_mod);
unrotated = reshape( unrotated, N, N );

% figure;
% imagesc( unrotated );
% axis image;


