function [mask_out] = fringemask( vismap_in, thres_vis, showplot )
% Function takes in a visibility map (preferrably from a reference
% hologram!) and produces a mask of the fringing area for use with masking
% out the nonsense phase or other image processing tricks for electron
% holograms.

if( ~exist( 'showplot') || isempty( showplot ) )
    showplot = false;
end

if( ~exist( 'thres_vis') || isempty( thres_vis ) )
    % Compute the histogram of the visiblity map
    [hist_vis, counts_vis] = hist( reshape( vismap_in, numel(vismap_in), 1), 888 );
    % Normalize just to give the fit a better chance of a good starting point
    hist_vis = hist_vis ./ max(hist_vis);
    % Fit a simple double-Gaussian
    [fit_refvis] = fit( counts_vis.', hist_vis.', 'gauss2' );

    % Go for a simple mid-point for now, I might try a confidence interval
    % later but dilation is probably an easier option.
    thres_vis = ( fit_refvis.b1 + fit_refvis.b2 ) ./ 2.0;
end


mask_out = 1.0.*( vismap_in > thres_vis );

% Do some dilation and erosion to smooth it out a bit.
% Now create the segmentation masks, and do the image opening and closing
se = strel( 'disk', 5 );
mask_out = imclose( imopen( mask_out, se ), se );


if( showplot )
    figure; movegui;
    figure; plot( counts_vis, hist_vis, '.b', counts_vis, feval(fit_refvis, counts_vis), 'r-' )
end