function [window] = apodization( apod_type, window_size, apod_size )
% Produces a variety of apodization windows.
%
%       [window] = apodization( apod_type, window_size, apod_size )
%
% window_size is the dimensions of the image the window is to be applied to 
% in pixels (may be rectangular).
%
% apod_size is the radius of the window in pixels (may be rectangular).
%
% If windowsize is one-dimensional (i.e. [2048 1]), will give a proper 1-D window
% 
% Valid apod_type's are:
%   'none' - returns array of ones
%   'tophat' - circular tophat window
%   'hamming' - square Hamming window
%   'hann' - circular von Hann window
%   'widehann' - a square von Hann window that tapers with radius A and is flat in the middle
%   'hann_sq' - square von Hann window
%   'hann3_sq' - square 3rd order von Hann window
%   'gauss' - circular Gaussian window
%   'gauss_trunc' - circular truncated Gaussian window
%   'butterworth.n' - n-th order rectangular butterworth filter

if( nargin < 1 )
    apod_type = 'hamming';
end

% Apply a reguar expression to get the filter order
regout = regexp( apod_type, '\.' );
if( isempty( regout ) )
    % Do nothing
else
    order = str2num(apod_type(regout+1:end));
    apod_type = apod_type(1:regout-1);
end

if( nargin < 2 )
    N = 512;
    M = 512;
else
    if( numel(window_size) == 1 )
        N = window_size;
        M = 1;
    elseif( numel(window_size) == 2 )
        N = window_size(2);
        M = window_size(1);
    end
end

if( nargin < 3 )
    U = N;
    V = M;
else % we have a apod_size
    if( numel(apod_size) == 1 )
        U = apod_size;
        V = 1;
    elseif( numel(window_size) == 2 )
        U = apod_size(2);
        V = apod_size(1);
    end
end

if( M == 1 || N == 1 )
    %% 1-D case
    N = max( M, N );
    xmesh = (-N/2+0.5:N/2-0.5);
    
    A = max( U, V );
    
    switch( lower( apod_type ) )    
        case 'none'
            window = ones(size(xmesh));
        case 'tophat'
            window = abs(xmesh) <= A;
        case 'hamming' 
            % Hamming window
            aperture = abs(xmesh) <= A;
            window = (27/50 + 23/50.*cos( 2.*pi.*xmesh./A )) .* aperture;
        case 'hann' 
            % von Hann window
            aperture = abs(xmesh) <= A;
            window = (0.5 + 0.5.*cos( pi.*xmesh./A ) ) .* aperture;
        case 'widehann'
            % a square von Hann window that tapers with radius A and is flat in
            % the middle
            % No aperture
            % ones( size( xmesh ) ) .* (xmesh <= N/2-A) & (xmesh >= -N/2+A) + ...
            window = ((0.5 + 0.5.*cos( 2.*pi.*xmesh./(2*A) + pi ) ) .* (xmesh < -N/2+A)) + ...
                    ((0.5 + 0.5.*cos( 2.*pi.*(N/2-xmesh)./(2*A) + pi ) ) .* (xmesh > N/2-A)) + ...
                    (ones( size( xmesh ) ) .* (xmesh <= N/2-A) & (xmesh >= -N/2+A));

        case 'hann_sq' 
            % square von Hann windowty
            aperture_sq = abs(xmesh) <= A;
            window = (0.5 + 0.5.*cos( 2.*pi.*xmesh./A)) .* aperture_sq;
        case 'gauss'
            % Gaussian window
            window = exp( -(xmesh./(A/2)).^2 );
        case 'gauss_trunc' 
            % Truncated Gaussian window
            aperture = abs(xmesh) <= A;
            window = exp( -(xmesh./(A/2)).^2 ) .* aperture;
        case 'hann3_sq' 
            % aperture_sq = xmesh < (U/2) & ymesh < (V/2);
            temp2 = -1*sin(pi*(A-1)/A)*(cos(2*pi*(xmesh+N/2)/A)-1) ...
                + 0.5*sin(pi*2*(A-1)/A)*(cos(4*pi*(xmesh+N/2)/A)-1) ...
                + -(1/3)*sin(pi*3*(A-1)/A)*(cos(6*pi*(xmesh+N/2)/A)-1);
            window = (sqrt(A*A)/(2*pi)).^2 .* temp2;
        case 'butterworth'
            if( ~exist( 'order' ) || isempty( order ) )
                disp( 'Apodization: not order given for Butterworth rectangular filter' )
                order = 4;
            end
            window = sqrt( 1 ./ (1 + (xmesh./(A/2)).^order) );    
        otherwise
            disp( 'Unknown 1-D apodization type' );
            window = ones( [N 1] );
    end
    
    if( M == 1 )
        % Above in the 1-D case we forced the first dimension to be the
        % non-zero dimension, so tranpose the result if it was actually the
        % second dimension that's supposed to be non-zero.
        window = window.'; 
    end
else 
    %% 2-D (default case)
    [xmesh, ymesh] = meshgrid( -N/2+0.5:N/2-0.5, -M/2+0.5:M/2-0.5 );

    switch( lower( apod_type ) )
        case 'none'
            window = ones(size(xmesh));
        case 'tophat'
            window = (xmesh./(U/2)).^2 + (ymesh./(V/2)).^2  <= 1;
        case 'hamming' 
            % Hamming window
            window = (27/50 + 23/50.*cos( 2.*pi.*xmesh./U )) .* (27/50 + 23/50.*cos( 2.*pi.*ymesh./V ));
        case 'hann' 
            % von Hann window
            aperture = (xmesh./(U/2)).^2 + (ymesh./(V/2)).^2  <= 1;
            window = (0.5 + 0.5.*cos( 2.*pi.*sqrt( (xmesh./U).^2 + (ymesh./V).^2) ) ) .* aperture;
        case 'hann_sq' 
            % square von Hann windowty
            aperture_sq = abs(xmesh) <= (U/2) & abs(ymesh) <= (V/2);
            window = (0.5 + 0.5.*cos( 2.*pi.*xmesh./U)) .* (0.5 + 0.5.*cos( 2.*pi.*ymesh./V )) .* aperture_sq;
        case 'widehann'
            ymesh = ymesh - min2(ymesh);
            yaperture_inv = ( ymesh < V );
            ywindow = (0.5 - 0.5.*cos( pi.*ymesh./V)) .* yaperture_inv + (1-yaperture_inv);
            ywindow = ywindow .* flipud( ywindow );
            
            xmesh  = xmesh - min2(xmesh);
            xaperture_inv = ( xmesh <  U );
            xwindow = (0.5 - 0.5.*cos( pi.*xmesh./U)) .* xaperture_inv + (1-xaperture_inv);
            xwindow = xwindow .* fliplr( xwindow );
            
            window = xwindow .* ywindow;
            
        case 'gauss'
            % Gaussian window
            window = exp( -( (xmesh./(U/2)).^2 + (ymesh./(V/2)).^2) );
        case 'gauss_trunc' 
            % Truncated Gaussian window
            aperture = (xmesh./(U/2)).^2 + (ymesh./(V/2)).^2  <= 1;
            window = exp( -( (xmesh./(U/2)).^2 + (ymesh./(V/2)).^2) ) .* aperture;
        case 'hann3_sq' 
            % aperture_sq = xmesh < (U/2) & ymesh < (V/2);
            temp1 = -1*sin(pi*(V-1)/V)*(cos(2*pi*(ymesh+M/2)/V)-1) ...
                + 0.5*sin(pi*2*(V-1)/V)*(cos(4*pi*(ymesh+M/2)/V)-1) ...
                + -(1/3)*sin(pi*3*(V-1)/V)*(cos(6*pi*(ymesh+M/2)/V)-1);
            temp2 = -1*sin(pi*(U-1)/U)*(cos(2*pi*(xmesh+N/2)/U)-1) ...
                + 0.5*sin(pi*2*(U-1)/U)*(cos(4*pi*(xmesh+N/2)/U)-1) ...
                + -(1/3)*sin(pi*3*(U-1)/U)*(cos(6*pi*(xmesh+N/2)/U)-1);
            window = (sqrt(U*V)/(2*pi)).^2 .* temp1 .* temp2;
        case 'butterworth'
            if( ~exist( 'order' ) || isempty( order ) )
                disp( 'Apodization: not order given for Butterworth rectangular filter' )
                order = 4;
            end
            window = sqrt( 1 ./ (1 + (xmesh./(U/2)).^order) ) .* sqrt( 1 ./ (1 + (ymesh./(V/2)).^order) );
        case 'butterworthr'
            if( ~exist( 'order' ) || isempty( order ) )
                disp( 'Apodization: not order given for Butterworth round filter' )
                order = 4;
            end
            window = sqrt( 1 ./ (1 + ( sqrt( (xmesh./(U/2)).^2 + (ymesh./(V/2)).^2) ).^order)  );
        otherwise
            disp( 'Unknown 2-D apodization type' );
            window = ones( [N M] );
    end
end



