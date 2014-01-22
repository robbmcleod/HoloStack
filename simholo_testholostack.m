N = 512;
N2 = N/2;
Nplus = N + 0; % Make specimen a little bigger than required for shifting and cropping
N4 = N/4;
[xmesh,ymesh] = meshgrid( (1:N)- N/2, (1:N) - N/2 );
rmesh = sqrt( xmesh.^2 + ymesh.^2 );

% Hologram parameters

theta = -0.278*pi;
k = 2.*pi.*125; % carrier wavenumber of the interference fringes
kx = k.*sin(theta-pi/2); % phase shifting for matching fringes axis to that of the envelope function
ky = k.*cos(theta-pi/2);
V = 0.35; % holographic visibilty
n = 300; % counts per pixel

% Object parameters
a_phi = 95; % radius of phase object in pixels

% Generate a top-hat
object = (rmesh < a_phi );

delta_phi = pi/3; % strength of phase object, in radians
delta_amp = 0.25; % strength of object in scattering potential

m = 10; % number of holograms to simulate

% Modulation Transfer Function
% Build NTF for applying to holograms
[qx_mesh, qy_mesh] = meshgrid( (-(N/2):N/2 - 1)./N, (-(N/2):N/2 - 1)./N );
q_mesh = sqrt( qx_mesh.^2 + qy_mesh.^2 );

% Experimental NTF recorded for 300 keV on the HF3300 USC upper camera
a1 = 0.31746289469589;
b1 = 0.137191468162481;
a2 = 0.295332639863577;
b2 = 0.318145714301296;
NTF_300kV = a1 ./ (1+(q_mesh./b1).^2) + a2 .* exp( -(q_mesh./b2).^2 );

% Reference
A = sqrt(n /2);
% A1 includes the object scattering
A2 = A .* ones( [N N] );
fringes_ref = 2 .* A2 .* A2 .* V .* cos( kx.*xmesh./N + ky.*ymesh./N  ); % NO PHASE
ref = fringes_ref + 2.*A2.^2;

ref_perfect = ifft2( ifftshift( NTF_300kV.* (fftshift(fft2( ref )))));

sb_pos = findSidebandMax( ref_perfect );
clear ref_perfect qx_mesh qy_mesh qmesh

mean_counts = zeros( [ m 1] );
var_counts = zeros( [m 1] );
offsets = zeros( [ m 2] );
pshifts = zeros( [m 1] );

[mag,ps] = HF3300mag( 3.23, 6.7, 6, 5 );
ps = ps*1E9; % convert to nm
% v_drift = 0.35./60./ps; % pixels per second drift
v_drift = 4


dn = 230/3*0.559; % about 43, given t_x = 3 s and 0.559 e-/count according to GATAN
% what is the relationship between 'mean_counts' and 'n'?  Counts are not
% conserved by the application of the various MTFs.
% Scaling appears to be mean = 0.453*n

% Random drift :create a drift series
s = RandStream('mcg16807', 'Seed',sum(100*clock));
RandStream.setDefaultStream(s);
blur = zeros( m, 2 );

t_x = 0.453.*n./dn;
drift_perframe = t_x.*v_drift;
% Linear drift
blur = drift_perframe.*ones( [m 2] );
% Random walk
% blur(:,:) = drift_perframe.*randn( m,2 );
drift = cumsum(blur,1);

% In the EDX holo, the mean phase shift was 0.0054 rad per frame.  No idea
% if this changes with exposure time (it probably does...)
% Random phase drift
phidrift_perframe = 0.01;
phiblur = phidrift_perframe.*randn( [m 1] );
phidrift = cumsum(phiblur);
% Set drift of first frame to zero, but leave blur intact for motion blur
% MTF purposes
drift(:,1) = drift(:,1) - drift(1,1);
drift(:,2) = drift(:,2) - drift(1,2);
phidrift = phidrift - phidrift(1);

A = sqrt(n /2);
% A1 includes the object scattering
A2 = A .* ones( [N N] );

holo_sim = zeros( [N N m] );
for i = 1:m
    % Sphere object mask (integrated through z)
    % thickness = 2 * sqrt( a^2 - r^2 )
    objectmask = sqrt( a_phi.^2 - (xmesh-drift(i,1)).^2 - (ymesh-drift(i,2)).^2 ) ...
        .* ((xmesh-drift(i,1)).^2 + (ymesh-drift(i,2)).^2 < a_phi.^2);
    objectmask = normalize( objectmask );

    % Object
    phase = objectmask .* delta_phi.* abs(imageShiftAndCrop( object, drift(i,:), [N N] )) + phidrift(i);
    A1 = A.*ones([N N]) - objectmask .* A.* delta_amp .* abs(imageShiftAndCrop( object, drift(i,:), [N N] ));

    % Build Hologram
    holo = A1.^2 + A2.^2 + 2 .* A1 .* A2 .* V .* cos( kx.*xmesh./N + ky.*ymesh./N + phase );
    % Build Reference
    % ref = 2.*A2.^2 + 2 .* A2 .* A2 .* V .* cos( kx.*xmesh./N + ky.*ymesh./N  ); % NO PHASE

    % Add per-pixel shot noise, only done when the specimen is at the
    % camera plane where the wave-function collapses.
    holo_sim(:,:,i) = HologramNoise( holo );

    % Build and apply motion-blur MTF
    % MTFblur = MTF_motionblur( [blur(k,i,1) blur(k,i,2)], N );
    % disp( 'DEBUG: no motion blur MTF (or camera NTF) being added!' )
    % holo = abs( ifft2( ifftshift( MTFblur .* (fftshift(fft2( holo ))))) );

    % Apply camera MTF
    holo_sim(:,:,i) = abs( ifft2( ifftshift( NTF_300kV .* (fftshift(fft2( holo_sim(:,:,i) ))))) );
    % ref_sim(:,:,i) = abs( ifft2( ifftshift( NTF_300kV .* (fftshift(fft2( ref_sim(:,:,i) ))))) );

    mean_counts(i) = mean2(holo_sim(:,:,i));
    var_counts(i) = var2(holo_sim(:,:,i));
end

hp = HoloReconP();
hp.doVismap = false;
hp.doCums = false;
hp.keepUnreg = true;
hp.dt = t_x;
hp.set( 'holoSize', [N N] );
hp.set( 'reconSize', [N2 N2] );
hp.set( 'doFresnelFilt', false );

% Register and sum hologram
HSholo = HoloStack( 'SimHolo', hp );

% Now reconstruct the holograms, with the summed reference used for
% normalization
HSholo.passSimHolo( holo_sim);
% HSref.passSimHolo( ref_sim );
clear holo_sim ref_sim

HSholo.register( 'MWAlign' ); 

figure;
for J = 1:m
    imagesc( angle(HSholo.holos(J).regside) );
    axis image;
    title( ['SimHolo for J = ', num2str(J) ] );
    pause( 1 );
end
