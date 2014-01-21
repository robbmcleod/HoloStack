function [filt_mage, count] = cimedfilt2( mage, sigma, N )
% Confidence Interval Median Filter 2-D
% [filt_mage, count] cimedfilt2( mage, sigma, N )
%   mage is input image
%   sigma is multiple of standard deviation to apply (optional, default 1)
%   N is size of median filter (N x N), 3 or 5 is typical (optional, def 5)
%   filt_mage is filtered image
%   count is the number of altered pixels
%
% The built in median filter function medfilt2 is a little too aggressive
% in that we would like to apply the result if and only if it exceeds
% a multiple of the standard deviation, i.e. a confidence interval filter.
% Standard deviation is a 68% confidence interval.  Other integers are:
%   1.0 :	0.6826895
%   2.0 :	0.9544997
%   3.0 :	0.9973002
%   4.0 :   0.9999366
%   5.0 :	0.9999994
% In this manner the majority of pixels can be left unchanged which is
% important for quantitative analysis.

if( nargin == 1 )
    sigma = 1;
    N = 5;
elseif( nargin == 2 )
    N = 5;
end

im_size = size( mage );

confidence = std2( mage ) * sigma;


med_mage = medfilt2( mage, [N N] );

diff_mage = abs(mage - med_mage) > confidence;

% medfilt2 seems to produce artefacts in the corners, so we will force
% those pixels to not be filtered.

diff_mage(1,1) = 0;
diff_mage(2,1) = 0;
diff_mage(1,2) = 0;

diff_mage(1,im_size(2)) = 0;
diff_mage(2,im_size(2)) = 0;
diff_mage(1,im_size(2)-1) = 0;

diff_mage(im_size(1),1) = 0;
diff_mage(im_size(1),2) = 0;
diff_mage(im_size(1)-1,1) = 0;

diff_mage(im_size(1),im_size(2)) = 0;
diff_mage(im_size(1)-1,im_size(2)) = 0;
diff_mage(im_size(1),im_size(2)-1) = 0;

% imagesc( ~diff_mage );
% axis image;
% title( 'Difference between filtered image and input' );

count = sum(sum( diff_mage ) );

% Use median filtered pixels where diff_mage == 1, and the original where
% they == 0
filt_mage = diff_mage .* med_mage + (~ diff_mage) .* mage;

return

