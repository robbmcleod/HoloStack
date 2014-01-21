
function [sbPos] = findSidebandMax( hologram, showflag )
% Function acts to locate the sideband for any given hologram.  I
% previously had this functionality in a bunch of different scripts, so I
% decided to incorporate it into one script so that changes could be made
% to all the reconstruction methods simultaneously.
%
% TO DO: Can we do better centration by bilinear interpolation?
% 
% Pass it a hologram, returns the [x y] coordinates of the sideband
% position.

% Size of hologram should be divisible by 2, but need not be square or a
% power of two.
hsize = size( hologram );
hsize2 = hsize/2;

if( ~exist( 'showflag' ) || isempty( showflag) )
    showflag = false;
end

x_axis = (1:hsize(2));
y_axis = (1:hsize(1));

[x_mesh, y_mesh] = meshgrid( x_axis - hsize(2)/2, y_axis - hsize(1)/2 );
rad_mesh = sqrt( x_mesh.^2 + y_mesh.^2 );
hamming = (27/50 + 23/50.*cos( 2.*pi.*x_mesh./hsize(2) )) .* (27/50 + 23/50.*cos( 2.*pi.*y_mesh./hsize(1) ));

fft_holo = fftshift( fft2(hologram .* hamming ) );

if( showflag )
    figure; movegui;
    imagesc( log( abs(fft_holo)) );
    axis image;
    title( 'Hamming window apodized hologram' );
end

% Autocorrelation is very strong, even outside of the central spot.
% Apply an apodization mask over the autocorrelation to suppress it.
a = max(hsize) / 128;
% generate x and y meshs for real and conjugate sidebands.
[x_mesh, y_mesh] = meshgrid( (1:hsize(2))-hsize(2)/2, (1:hsize(1))-hsize(1)/2);
rad_mesh = sqrt( x_mesh.^2 + y_mesh.^2 );
% Inverse Hann window
apodization = (rad_mesh >= a) + (rad_mesh < a) .* (0.5 - 0.5 .* cos( pi.*rad_mesh./a ));
% Apply apodization
apod_holo = fft_holo.*apodization;
% clear x_mesh y_mesh rad_mesh apodization

% figure; movegui;
% imagesc( log( abs( apod_holo ) ) );
% axis image;
% title( 'Hamming window apodized hologram' );


% Chop up the FFT into quadrants so you can figure out which one contains
% the sidebands.  Quadrant 3 and 4 are not really necessary, since the 
% mirror is the conjugate frequencies.
% NOTE: (hsize/2+1,hsize/2+1) is normally where the autocorrelation is.
quad1 = abs( apod_holo( 1:hsize2(1)-1, hsize2(2)+2:hsize(2) ) );
quad2 = abs( apod_holo( 1:hsize2(1)-1, 1:hsize2(2)-1 ) );
quad3 = abs( apod_holo( hsize2(1)+2:hsize, 1:hsize2(2)-1 ) );
quad4 = abs( apod_holo( hsize2(1)+2:hsize, hsize2(2)+2:hsize(2) ) );


% figure;
% subplot(2,2,1), imagesc(log(quad2));
% title( 'Log of Quadrant 2' );
% axis image;
% subplot(2,2,2), imagesc(log(quad1));
% title( 'Log of Quadrant 1' );
% axis image;
% subplot(2,2,3), imagesc(log(quad3));
% title( 'Log of Quadrant 3' );
% axis image;
% subplot(2,2,4), imagesc(log(quad4));
% title( 'Log of Quadrant 4' );
% axis image;

maxquad1 = max(max(quad1));
maxquad2 = max(max(quad2));

if( maxquad1 > maxquad2 )
    % In quadrant 1
%     figure;
%     imagesc(log(quad1) );
%     title( 'Quadrant 1' );
%     axis image;

    % Curve fit toolbox requires column vectors as inputs
    xsection =  sum( quad1, 1 )';
    ysection = sum( quad1, 2 );
    xscale = (hsize2(2)+2:hsize(2))';
    yscale = (1:hsize2(1)-1)';
else
% In quadrant 2
%     figure;
%     imagesc(log(quad2) );
%     title( 'Quadrant 2' );
%     axis image;

    % Curve fit toolbox requires column vectors as inputs
    xsection =  sum( quad2, 1 ).';
    ysection = sum( quad2, 2 );
    xscale = (1:hsize2(2)-1).';
    yscale = (1:hsize2(1)-1).';
end
clear quad1 quad2 quad3 quad4 apod_ref

% Background subtraction: fit a power law a*x^b + c curve to the
% cross-sections and subtract them.  Power law is roughly equivalent to a
% quadratic in terms of fit but better handles spikes in the tails from the
% autocorrelation.
% - Use of the 'Robust' parameter 'Bisquare' results in a much better
% correlation coefficient.
% [xfit, xerror, xout] = fit( xscale, xsection, 'power2', 'Robust','Bisquare' );
% [yfit, yerror, yout] = fit( yscale, ysection, 'power2', 'Robust','Bisquare' );
[xfit, xerror, xout] = fit( xscale, xsection, 'power2' );
[yfit, yerror, yout] = fit( yscale, ysection, 'power2' );

% figure;
% hold on;
% scatter( xscale, xsection, 'x' )
% plot( xscale, xfit.a*xscale.^(xfit.b) + xfit.c, 'r')
% title( 'X-cross section with Background Fit' );
% hold off;
% 
% figure;
% hold on;
% scatter( yscale, ysection, 'x' )
% plot( yscale, yfit.a*yscale.^(yfit.b) + yfit.c, 'r')
% title( 'Y-cross section with Background Fit' );
% hold off;

% Subtract the fitted background from the cross-sections.
xsection = xsection - ( xfit.a * xscale.^(xfit.b) + xfit.c );
ysection = ysection - ( yfit.a * yscale.^(yfit.b) + yfit.c );

%fitresult.b1 is the mean
[temp, xmean] = max( xsection );
[temp, ymean] = max( ysection );

% Need to scale the result for x if it starts in the 1st quadrant
if( xscale(1) > hsize2(2) )
    xmean = xmean + xscale(1)-1;
else
    xmean = xmean;
end
% ymean is fine as is, since we don't compute from 3rd or 4th quadrants
ymean = ymean;


sbPos = [ymean xmean];