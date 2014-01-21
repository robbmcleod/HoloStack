function [out_phase] = FouUnwrap( in_phase, iterations )
% Usage:
%   [out_phase] = FouUnwrap( in_phase, iterations )
% Iterations is the number of iterations to force (i.e. it is a minimum,
% not a maximum).
%
% Originally written for Digital Micrograph by Marvin Schofield (schofiel@uwm.edu).
% Ported to MATLAB by Robert A. McLeod (robbmcleod@gmail.com).
% 
% Cite: Marvin A. Schofield and Yimei Zhu. "Fast phase unwrapping algorithm
% for interferometric applications." Optics Letters 28 (14) (2003), 1194.

if nargin < 2
    iterations = 0;
end

[x y] = size(in_phase);

x2 = x*2;
y2 = y*2;
xy = x*y;

% Compute 2D radius^2 function
[xmesh,ymesh] = meshgrid( -y:y-1, -x:x-1 );
g2 = (xmesh.^2 + ymesh.^2) .* pi.^2 ./ xy;

g2 = fftshift(g2); % Need to do an FFT shift to get proper convolution in k-space
% figure;
% imagesc(g2);
% axis image
% colormap gray
% title('g2');

% ig2 is the reciprocal of g2
ig2 = 1./g2;
%ig2(x+1,y+1) = ig2(x,y+1); % Deal with the divide by zero; wonder what this does...
ig2(1,1) = 0; % Due to the FFTShift the singularity is at (1,1)

% figure;
% imagesc(ig2);
% axis image
% colormap gray
% title('ig2');

%normalize phase
phase1 = in_phase - mean(mean(in_phase));
%tile phase to setup periodicity
phase = [ phase1 fliplr(phase1); flipud(phase1) flipud(fliplr(phase1)) ];
clear phase1;

count = 1;

fftw('planner','patient'); % Tell FFTW to find the fastest transform
cosphase = cos(phase); % Should be real
sinphase = sin(phase); % Should be real
%imphase is the Laplacian of the phase
imphase = real(ifft2( -fft2(sinphase).*g2) ) .* cosphase - real(ifft2( -fft2(cosphase).*g2 ) ) .* sinphase;

% figure; 
% imagesc(imphase);
% axis image;
% colormap('gray');
% title( 'Laplacian of phase... Imphase' )

% r = 1E20; % Init really big number, r(esidual) is the goodness of the algorithm to the fit phase
r_old = -1; %The residual from the last iteration.
count_r = 0; %If the unwrapping isn't improving start counting so script terminates.

oldphase = phase;
% source = zeros( [x2 y2] );
newphase = zeros( [x2 y2] );

index = 0;
while( true )
	%calc fourlap(wrapped phase); source
    % 	temp1=real(ifft(-realfft(oldpha)*g2))
	source = imphase - real(ifft2(-fft2(oldphase).*g2));
    
	%get n-map, i.e. number of phase wraps.
	en = real(ifft2(-fft2(source).*ig2))/(2*pi);

	%make into integer
	en = round( en );
 
	%calc new phase
	newphase = (oldphase + (en*2*pi) );
    
    %the residual 'r' is computationally expensive, anything better?
	r = sum(sum( min( abs(oldphase-newphase), 1) ));
    disp( horzcat( num2str(count), ': Residual # of pixels to unwrap = ', num2str( r ) ) )
    
    % iterator
    count = count+1;
    
    % Check to stop loop
    if r >= r_old
        % Either the phase unwrap isn't getting better or it's getting
        % worse
        count_r = count_r + 1;
    else
        count_r = 0;
    end
    
    r_old = r;
    
    if (r == 0 || count_r >= 2) && index >= iterations
        % Break if residual is zero or if it stops moving
        break;
    end
    
	oldphase = newphase; %speed up by passing reference, if possible
    index = index + 1;
end


%extract phase from top-left quadrant
out_phase = newphase(1:x,1:y);
% figure;
% imagesc( out_phase );
% axis image;
% colormap gray;
% title( 'Unwrapped Phase' );
return;




