function [Clim] = histClim( target, sigma )
% Function uses the cumulative histogram to limit the contrast limits to
% the given confidence interval (so sigma = 2.0 cuts out 2.5% of the pixels
% on either side of the histogram).

if( nargin < 2 )
    sigma = 2.0;
end
% Now find what sigma translates into based on erf
ci = (1 - erf( sigma/sqrt(2))) / 2;

if( ndims( target ) >= 3 )
    % I am probably passing in something of size [N N 1] in this case
    target = squeeze(target);
end

target1D = reshape( target, numel(target),1);

% Eliminate any Nans or Infs -- indicates a mask
target1D = target1D( ~isnan(target1D) );
target1D = target1D( ~isinf(target1D) );

% Eliminate any crazy outliers, outside 5 sigma
mean1D = mean( target1D );
std1D = std( target1D );
target1D( (target1D > mean1D + 5*std1D) | (target1D < mean1D - 5*std1D) ) = [];

% max( target1D )
% min( target1D )

% it's ok to have a lot of bins, because we're taking the cumulative
% histogram.
[htarget, hintensity] = hist( target1D, ceil(sqrt(numel(target1D))));
% Find the cumulative distribution of the histogram
cumsumtarget = cumsum( htarget );
% Normalize
cumsumtarget = cumsumtarget ./ cumsumtarget(end);
% 
% figure; movegui;
% plot( hintensity, cumsumtarget );
% xlabel( 'Pixel intensity (DN/pix)' );



% Find the intensity positions that correspond to the cut-offs.
Clim(1) = hintensity( find( cumsumtarget > ci, 1 ) );
Clim(2) = hintensity( find( cumsumtarget < 1 - ci, 1, 'last' ) );

