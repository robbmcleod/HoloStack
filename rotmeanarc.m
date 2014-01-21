function [rmean, raxis, weights] = rotmeanarc( input_image, angle_range )
% The function RotMean calculates the rotational average for a
% two-dimensional matrix, taking the centre to be at the middle pixel.
%
% The additional arc functionality is for Fourier filtering, where we want
% to remove Fresnel fringes and replace them with something sensible.
% Therefore we do rotational average but with data only from within the
% range angle_range(1) < theta < angle_range(2)

N = floor(size( input_image,1 )./2);
M = floor(size( input_image,2 )./2);
%rmax is the length of the radial mean vector
rmax = ceil( sqrt( N.^2 + M.^2 ) ) + 1;

rmean = zeros( [rmax 1] );
weights = zeros( [rmax 1] );

[xmesh, ymesh] = meshgrid(-M:M-1,-N:N-1);
r = sqrt( xmesh.^2 + ymesh.^2 );
rfloor = floor( r );
remain = r - rfloor;

% angle mesh
theta = atan2( xmesh, ymesh );
arcmesh = 1.0 .*(theta > angle_range(1) ) .* (theta < angle_range(2) );

% figure; movegui;
% imagesc( abs(arcmesh .* input_image), histClim(abs(arcmesh .* input_image)) );
% axis image;

for I = 1:N*2
    for J = 1:M*2
        % Check indexing -- may be causing issues with MATLAB arrays
        % counting from 1.
        rmean(rfloor(I,J)+1) = input_image(I,J)*(1-remain(I,J)) + arcmesh(I,J).*( rmean(rfloor(I,J)+1) );
        rmean(rfloor(I,J)+2) = input_image(I,J)*remain(I,J) + arcmesh(I,J).*( rmean(rfloor(I,J)+2) );
        
        % Calculate the area of each pixel as the resulting mean needs to
        % be divided by the total area.  Since we are only summing the area
        % over one quadrant we need to multiply it by 4 later.
        weights(rfloor(I,J)+1) = weights(rfloor(I,J)+1) + arcmesh(I,J).*( (1-remain(I,J)) );
        weights(rfloor(I,J)+2) = weights(rfloor(I,J)+2) + arcmesh(I,J).*( remain(I,J) );
    end
end
%
rmean = (rmean ./ weights);
raxis = 0:numel(rmean)-1;



