function [map_out, xvect, yvect] = densitymap( x, y, bin, limits )
% Robert McLeod
% 02 Oct 2012
% Quick and dirty MATLAB density plot from 1-D data (vectorize 2-D data
% using reshape )

% x and y must be the same length

% TODO: add functionality for the bin positions
if( exist('bin' ) )
    binx = bin(1);
    biny = bin(2);
else
    binx = 64;
    biny = 64;
end

if( exist('limits' ) )
    if( strcmp( limits, 'minmax' ) )
        xlim(1) = min( x );
        xlim(2) = max( x );
        ylim(1) = min( y );
        ylim(2) = max( y );
    % elseif( strcmp( limits, 'clim' ) )
    else
        xlim = histClim( x, 3 );
        ylim = histClim( y, 3 );
    end
    
else
    xlim = histClim( x, 3 );
    ylim = histClim( y, 3 );
end

xvect = linspace(xlim(1),xlim(2),binx);
yvect = linspace(ylim(1),ylim(2),biny);

% [xmesh, ymesh] = meshgrid( linspace(xmin,xmax,binx), linspace(ymin,ymax,biny) );

map_out = zeros( [binx biny] );
for I = 1:numel(x)
    % Might want to replace with some bilinear interpolation, but this will work for
    % now
    x_pos = find( xvect >= x(I), 1, 'first' );
    y_pos = find( yvect >= y(I), 1, 'first' );
    % Indexing could have potential problems
    map_out(x_pos,y_pos) = map_out(x_pos,y_pos) + 1;
end

% imagesc( xvect, yvect, map_out );
