
N = 1024;
rescale = 2;

hp = HoloReconP();
hp.set( 'a', 0.5 );
hp.set( 'dt', 16 );
hp.set( 'holoSize', [N N] );
hp.set( 'reconSize', [N/rescale N/rescale] );
% hp.set( 'ps_holo', 0.615/38.8 );
hp.set( 'doFresnelFilt', true);
hp.set( 'keepRaw', false );
% hp.set( 'filtName', 'gauss_trunc' );
hp.set( 'filtName', 'hann' );
hp.set( 'apodizationName', 'none' );
hp.set( 'vmFiltName', 'hann' );
% hp.set( 'filtName', 'hann' );
% hp.set( 'vmFiltName', 'hann' );
hp.set( 'maxShiftPerFrame', 6 );

refname = 'bingo.ref';
holoname = 'bingo.';

refstruct1 = DM3Import( [refname, '1'] );
hp.set( 'sbPos', findSidebandMax( refstruct1.image_data, false ) );

% Create HoloStack object
HoloA = HoloStack( holoname, hp );

% Define regions of interest for x-correlation and phase matching
hp.xcMethod = 'general';
HoloA.drawxcMaskRect()
HoloA.drawpmMaskRect()

% Reconstruct all the holograms
HoloA.readAndRecon()
% Align and registered all the holograms
HoloA.register( 'MWAlign' );

return

bigfig;
for J = 1:HoloA.numFrames
    imagesc( HoloA.holos(J).regcenter );
    axis image
    title( [ 'J = ', num2str(J) ] )
    pause( 0.5 );
end

% RefA = HoloStack( refname, hp );
% RefA.readAndRecon()
% RefA.setAsReference( HoloA );

HoloA.plotAll();
% HoloA.plotAll( 2.5, RefA );

HoloA.makeMovie('regcenter', ['bingo_regcenter'] );

unphaseA = FouUnwrap( angle( HoloA.holoSum.regside ) );
refphaseA = FouUnwrap( angle( RefA.holoSum.regside ) );
unphaseA = unphaseA(1:end-30,:);
refphaseA = refphaseA(1:end-30,:);

normphaseA = unphaseA - refphaseA;
maxis = (1:size(normphaseA,1));
naxis = (1:size(normphaseA,2));

HoloA_offsets = HoloA.getOffsets();
HoloA_pshifts = HoloA.getPhaseShifts();
RefA_pshifts = RefA.getPhaseShifts();

[xData, yData, zData] = prepareSurfaceData( naxis, maxis, normphaseA );

% Fit model to data.
[fit_grad] = fit( [xData, yData], zData, 'poly11');
phaseA_grad = zeros( size( normphaseA ) );
for J = maxis
    phaseA_grad(J,:) = feval( fit_grad, naxis, J );
end

normsubphaseA = normphaseA - phaseA_grad;

figure;
imagesc( normsubphaseA, histClim( normsubphaseA, 2.2) );
title( 'Normalized phase' );
axis image; 
colorbar();
% ccout = normxcorr2_general( unphaseA, refphaseA );

prof_phaseA = profile_int( normsubphaseA, [30 465], [249 216], 20 );

figure;
plot( prof_phaseA, 'LineWidth', 2.5 );
xlabel( 'Pixel position' );
ylabel( 'Phase shift (rad)' );

regvisA = HoloA.holoSum.regvismap;
figure;
imagesc( regvisA, [0.1 0.13] );
axis image;
title( 'Averaged visibility' );

  
