function [bin_mage] = rebin2( mage, N, M )
% Re-bin an image into N x M elements using a fast vector method.  Requires
% that M and N can be formed from the prime factors {2,3,5,7} which should
% be sufficient for most image processing needs.
%   [bin_mage] = rebin2( mage, N, M )
% where
%   mage : input 2-D image
%   N : y-length to bin mage into (optional, default of 2)
%   M : x-length to bin mage into in X (optional, defaults to M = N )
%   bin_mage: output 2-D image
% Note that this method conserves counts, i.e. it computes the sum of a bin
% not the mean.
% Exception: if you try to rebin by a number that is not an integer factor
% of the original image, the script will crop out pixels on the bottom and
% right to get to an integer, i.e. re-binning a 256x256 image by 3x3 will
% result in a 85x85 image.

if( nargin == 1 )
    N = 2;
    M = N;
elseif( nargin == 2 )
    M = N;
end

% Easiest way of rebinning is to apply it in one direction 
% and then the other.  The absolute fastest method is to factor M and N 
% into prime factors and rebin seperately for each one, using dedicated
% functions.  I have functions for this up to the factor of 7.  Past that
% will issue a warning.

% Initialize
bin_mage = mage;

for nfactor = factor( N );
    switch nfactor
        case 2
            bin_mage = binby2( bin_mage, 1 );
        case 3
            bin_mage = binby3( bin_mage, 1 );
        case 5
            bin_mage = binby5( bin_mage, 1 );
        case 7
            bin_mage = binby7( bin_mage, 1 );
        otherwise
            warning( 'Rebinning of N is not a factor of {2,3,5,7} and will fail' );
    end
end

for mfactor = factor( M );
    switch mfactor
        case 2
            bin_mage = binby2( bin_mage, 2 );
        case 3
            bin_mage = binby3( bin_mage, 2 );
        case 5
            bin_mage = binby5( bin_mage, 2 );
        case 7
            bin_mage = binby7( bin_mage, 2 );
        otherwise
            warning( 'Rebinning of M is not a factor of {2,3,5,7} and will fail' );
    end
end

end %rebin2

function [bin_ray] = binby2( ray, dim )
    rsiz = size( ray );
    step = 2;
    if dim == 1
        stop = floor(rsiz(1)/step)*step;
        bin_ray = ray( 1:step:stop, : ) + ray( 2:step:stop, : );
    else % dim == 2
        stop = floor(rsiz(2)/step)*step;
        bin_ray = ray( :, 1:step:stop ) + ray( :, 2:step:stop );
    end
end

function [bin_ray] = binby3( ray, dim )
    rsiz = size( ray );
    step = 3;
    if dim == 1
        stop = floor(rsiz(1)/step)*step;
        bin_ray = ray( 1:step:stop, : ) + ray( 2:step:stop, : ) + ray( 3:step:stop, : );
    else % dim == 2
        stop = floor(rsiz(2)/step)*step;
        bin_ray = ray( :, 1:step:stop ) + ray( :, 2:step:stop ) + ray( :, 3:step:stop );
    end
end

function [bin_ray] = binby5( ray, dim )
    rsiz = size( ray );
    step = 5;
    if dim == 1
        stop = floor(rsiz(1)/step)*step;
        bin_ray = ray( 1:step:stop, : ) + ray( 2:step:stop, : ) ...
            + ray( 3:step:stop, : ) + ray( 4:step:stop, : ) + ray( 5:step:stop, : );
    else % dim == 2
        stop = floor(rsiz(2)/step)*step;
        bin_ray = ray( :, 1:step:stop ) + ray( :, 2:step:stop ) ...
            + ray( :, 3:step:stop ) + ray( :, 4:step:stop ) + ray( :, 5:step:stop );
    end
end

function [bin_ray] = binby7( ray, dim )
    rsiz = size( ray );
    step = 7;
    if dim == 1
        stop = floor(rsiz(1)/step)*step;
        bin_ray = ray( 1:step:stop, : ) + ray( 2:step:stop, : ) ...
            + ray( 3:step:stop, : ) + ray( 4:step:stop, : ) + ray( 5:step:stop, : ) ...
            + ray( 6:step:stop, : ) + ray( 7:step:stop, : );
    else % dim == 2
        stop = floor(rsiz(2)/step)*step;
        bin_ray = ray( :, 1:step:stop ) + ray( :, 2:step:stop ) ...
            + ray( :, 3:step:stop ) + ray( :, 4:step:stop ) + ray( :, 5:step:stop ) ...
            + ray( :, 6:step:stop ) + ray( :, 7:step:stop );
    end
end