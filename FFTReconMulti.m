% Reconstruction script for holography
%
% Generally designed to work with the HoloStack and HoloClass system.
%  Usage:
%     [reconHolo_out, sbPos_out] = FFTReconMulti( hs, hp )
% hs = HoloStack or a HoloClass object
% hp = HoloReconP parameter object
%
% HOLOSTACK SOFTWARE LICENSE
% Robert A. McLeod
% 16 January 2014
%
% 1.	Preamble: This Agreement, signed on Jan 16, 2014 (hereinafter: Effective Date) governs the relationship between David Cooper, a private person, (hereinafter: Licensee) and Robert A. McLeod, a private person whose principal place of business is 45c quai du Drac, 38600 Fontaine, France, France (Hereinafter: Licensor). This Agreement sets the terms, rights, restrictions and obligations on using HoloStack (hereinafter: The Software) created and owned by Licensor, as detailed herein
% 2.	License Grant: Licensor hereby grants Licensee a Personal, Non-assignable & non-transferable, Non-commercial, Including the rights to create but not distribute derivative works, Non-exclusive license, all with accordance with the terms set forth and other legal restrictions set forth in 3rd party software used while running Software.
% 2.1.	Limited: Licensee may use Software for the purpose of:
% 2.1.1.	Running Software on Licensee’s Computer[s] and Server[s];
% 2.1.2.	Allowing 3rd Parties to run Software on Licensee’s Computers[s] and Server[s];
% 2.1.3.	Publishing Software’s output to Licensee and 3rd Parties;
% 2.1.4.	Distribute verbatim copies of Software’s output (including compiled binaries);
% 2.1.5.	Modify Software to suit Licensee’s needs and specifications.
% 2.2.	Binary Restricted: Licensee may sublicense Software as a part of a larger work containing more than Software, distributed solely in Object or Binary form under a personal, non-sublicensable, limited license. Such redistribution shall be limited to unlimited codebases.
% 2.3.	Non Assignable & Non-Transferable: Licensee may not assign or transfer his rights and duties under this license.
% 2.4.	Non-Commercial: Licensee may not use Software for commercial purposes. for the purpose of this license, commercial purposes means that a 3rd party has to pay in order to access Software or that the Website that runs Software is behind a paywall.
% 2.5.	Including the Right to Create Derivative Works: Licensee may create derivative works based on Software, including amending Software’s source code, modifying it, integrating it into a larger work or removing portions of Software, as long as no distribution of the derivative works is made
% 2.6.	With Attribution Requirements: Public works derived from the software should be refer to Robert A. McLeod, Michael Bergen, and Marek Malac, "Phase error and spatial resolution for off-axis electron hologram series," In press (2013).
% 3.	Term & Termination: The Term of this license shall be until terminated. Licensor may terminate this Agreement, including Licensee’s license in the case where Licensee :
% 3.1.	became insolvent or otherwise entered into any liquidation process; or
% 3.2.	exported The Software to any jurisdiction where licensor may not enforce his rights under this agreements in; or
% 3.3.	Licensee was in breach of any of this license's terms and conditions and such breach was not cured, immediately upon notification; or
% 3.4.	Licensee in breach of any of the terms of clause 2 to this license; or
% 3.5.	Licensee otherwise entered into any arrangement which caused Licensor to be unable to enforce his rights under this License.
% 4.	Payment: In consideration of the License granted under clause 2, Licensee shall pay Licensor a fee, via Credit-Card, PayPal or any other mean which Licensor may deem adequate. Failure to perform payment shall construe as material breach of this Agreement.
% 5.	Upgrades, Updates and Fixes: Licensor may provide Licensee, from time to time, with Upgrades, Updates or Fixes, as detailed herein and according to his sole discretion. Licensee hereby warrants to keep The Software up-to-date and install all relevant updates and fixes, and may, at his sole discretion, purchase upgrades, according to the rates set by Licensor. Licensor shall provide any update or Fix free of charge; however, nothing in this Agreement shall require Licensor to provide Updates or Fixes.
% 5.1.	Upgrades: for the purpose of this license, an Upgrade shall be a material amendment in The Software, which contains new features and or major performance improvements and shall be marked as a new version number. For example, should Licensee purchase The Software under version 1.X.X, an upgrade shall commence under number 2.0.0.
% 5.2.	Updates: for the purpose of this license, an update shall be a minor amendment in The Software, which may contain new features or minor improvements and shall be marked as a new sub-version number. For example, should Licensee purchase The Software under version 1.1.X, an upgrade shall commence under number 1.2.0.
% 5.3.	Fix: for the purpose of this license, a fix shall be a minor amendment in The Software, intended to remove bugs or alter minor features which impair the The Software's functionality. A fix shall be marked as a new sub-sub-version number. For example, should Licensee purchase Software under version 1.1.1, an upgrade shall commence under number 1.1.2.
% 6.	Support: Software is provided under an AS-IS basis and without any support, updates or maintenance. Nothing in this Agreement shall require Licensor to provide Licensee with support or fixes to any bug, failure, mis-performance or other defect in The Software.
% 6.1.	Bug Notification: Licensee may provide Licensor of details regarding any bug, defect or failure in The Software promptly and with no delay from such event; Licensee shall comply with Licensor's request for information regarding bugs, defects or failures and furnish him with information, screenshots and try to reproduce such bugs, defects or failures.
% 6.2.	Feature Request: Licensee may request additional features in Software, provided, however, that (i) Licensee shall waive any claim or right in such feature should feature be developed by Licensor; (ii) Licensee shall be prohibited from developing the feature, or disclose such feature request, or feature, to any 3rd party directly competing with Licensor or any 3rd party which may be, following the development of such feature, in direct competition with Licensor; (iii) Licensee warrants that feature does not infringe any 3rd party patent, trademark, trade-secret or any other intellectual property right; and (iv) Licensee developed, envisioned or created the feature solely by himself.
% 7.	Liability:  To the extent permitted under Law, The Software is provided under an AS-IS basis. Licensor shall never, and without any limit, be liable for any damage, cost, expense or any other payment incurred by Licensee as a result of Software’s actions, failure, bugs and/or any other interaction between The Software  and Licensee’s end-equipment, computers, other software or any 3rd party, end-equipment, computer or services.  Moreover, Licensor shall never be liable for any defect in source code written by Licensee when relying on The Software or using The Software’s source code.
% 8.	Warranty:  
% 8.1.	Intellectual Property: Licensor hereby warrants that The Software does not violate or infringe any 3rd party claims in regards to intellectual property, patents and/or trademarks and that to the best of its knowledge no legal action has been taken against it for any infringement or violation of any 3rd party intellectual property rights.
% 8.2.	No-Warranty: The Software is provided without any warranty; Licensor hereby disclaims any warranty that The Software shall be error free, without defects or code which may cause damage to Licensee’s computers or to Licensee, and that Software shall be functional. Licensee shall be solely liable to any damage, defect or loss incurred as a result of operating software and undertake the risks contained in running The Software on License’s Server[s] and Computers[s].
% 8.3.	Prior Inspection: Licensee hereby states that he inspected The Software thoroughly and found it satisfactory and adequate to his needs, that it does not interfere with his regular operation and that it does meet the standards and scope of his computer systems and architecture. Licensee found that The Software interacts with his development, website and server environment and that it does not infringe any of End User License Agreement of any software Licensee may use in performing his services. Licensee hereby waives any claims regarding The Software's incompatibility, performance, results and features, and warrants that he inspected the The Software.
% 9.	No Refunds: Licensee warrants that he inspected The Software according to clause 7(c) and that it is adequate to his needs. Accordingly, as The Software is intangible goods, Licensee shall not be, ever, entitled to any refund, rebate, compensation or restitution for any reason whatsoever, even if The Software contains material flaws.
% 10.	Indemnification: Licensee hereby warrants to hold Licensor harmless and indemnify Licensor for any lawsuit brought against it in regards to Licensee’s use of The Software in means that violate, breach or otherwise circumvent this license, Licensor's intellectual property rights or Licensor's title in The Software. Licensor shall promptly notify Licensee in case of such legal action and request Licensee’s consent prior to any settlement in relation to such lawsuit or claim.
% 11.	Governing Law, Jurisdiction: Licensee hereby agrees not to initiate class-action lawsuits against Licensor in relation to this license and to compensate Licensor for any legal fees, cost or attorney fees should any claim brought by Licensee against Licensor be denied, in part or in full.


function [reconHolo_out, sbPos_out] = FFTReconMulti( hs, hp )

if( nargin < 2 )
    disp( 'FFTReconMulti: Warning, no holoparam passed in' );
    % Make a default parameters object
    hp = HoloReconP();
end
if( nargin < 1 )
    disp( 'FFTReconMulti: Error, no holostruct passed in' );
    return;
end

% Check to see what hs is, holostruct can be any one of:
%   1.) a 2-D array of doubles
%   2.) a HoloClass object, empty except for a filename
if( isobject( hs ) )
    % hc = hs.copy();
    hc = hs;
    dm3struct = DM3Import( hc.filename );
    hc.holo = dm3struct.image_data;
    
    % TO DO: import other parameters from dm3struct
    clear dm3struct;
elseif( isnumeric( hs ) )
    % Make a new empty HoloClass
    hc = HoloClass();
    hc.holo = hs;
end

%% Pre-processing

% Check to see if darkref and gainref are empty or not, for reference
% normalization
if( ~isempty( hp.darkRef ) )
    hc.holo = hc.holo - hp.darkRef;
end
if( ~isempty( hp.gainRef ) )
    hc.holo = hc.holo ./ hp.gainRef; % Make with findGainRef.m
end

if( hp.doMedFilt )
    % My confidence interval median filter function only alters pixels from a
    % median filtered image that are outside of some confidence interval,
    % 2.0 sigma ~= 95 %.
    % This is quite slow so I do not do it for reconstruction often
    hc.holo = cimedfilt2( hc.holo, hp.medFiltSigma );
end

if( isempty( hp.get( 'sbPos' ) ) )
    % Not provided with position
    % findSidebandMax has some special processing of the hologram.
    hp.sbPos = findSidebandMax( hc.holo );
end % nargin if

%% Transform to Fourier-space

% Size of hologram should be divisible by even, but need not be square or a
% power of two.
hp.holoSize = size( hc.holo );
hsize2 = hp.holoSize/2;
cbPos = hsize2 + 1;

% Apply real-space apodization, if desired, and FFT
if( strcmp( hp.apodizationName, 'none' ) ~= 1 )
    fftHolo = fftshift( fft2( hc.holo .* apodization( hp.apodizationName, hp.holoSize ) ) );
else
    fftHolo = fftshift( fft2( hc.holo ) );
end

hp.q_c = sqrt( sum( (hp.sbPos - hsize2).^2 ) );
% Create a new matrix of size (2*radius)+1 x (2*radius)+1 for side-band.
cradius = ceil(hp.q_c);
radApod = floor(cradius*hp.a); % a is the radius of the hard aperture (i.e. Hann window)

% Check that we don't exceed the bounds of the detector
fxt = floor(hp.sbPos(2));
fyt = floor(hp.sbPos(1));
if( fxt - radApod - 0.5 < 0 || fyt - radApod - 0.5 < 0 || fxt + 0.5 + radApod > hp.holoSize(2) || fyt + 0.5 + radApod > hp.holoSize(1) )
    error( 'FFTReconMulti: sideband aperture extends outside of hologram data range' );
end

%% Fresnel-fringes filter application
if( hp.doFresnelFilt )
    % theta = atan2( hp.sbPos(2) - cbPos(2), hp.sbPos(1) - cbPos(1) )
    theta = atan2( hp.sbPos(1) - cbPos(1), hp.sbPos(2) - cbPos(2) );
    backgroundRotmean = rotmeanarc( abs(fftHolo), [theta + hp.ffCutAngle, unwrap( theta + pi ) - hp.ffCutAngle]);

    backgroundRotmean = smooth( backgroundRotmean, hp.ffSmoothSpan );
    % Sometimes there are Infs in here, so delete them
    backgroundRotmean( isinf(backgroundRotmean) ) = 0.0;
    backgroundRotmean( isnan(backgroundRotmean) ) = 0.0;

    fftBackground = inv_rotmean( backgroundRotmean  );
    fftBackground = fftBackground(2:end-1, 2:end-1);

    % Build a Fresnel filter from a 12th order Butterworth filter
    butterwidth = hp.ffCutHalfWidth*2+1;
    butterlength = floor( cradius.*( 1 - hp.ffSideRadCut ) ) - floor( hp.ffSideRadCut .*cradius ) + 1;
    % Force butterlength to be even?
%     [ butterwidth + hp.ffSoftPad, butterlength+hp.ffSoftPad]
    butter = apodization( hp.ffFiltName,  [ butterwidth + hp.ffSoftPad, butterlength+hp.ffSoftPad], [butterwidth, butterlength] );
    bs2 = size(butter)/2;
    bs2(1) = bs2(1) - 0.5;
    % Force bs2 to be even?
    bs2(2) = floor(bs2(2));

    % Apply Fresnel filter
    fresFilt = zeros( hp.holoSize );
%      size( butter )
%      [numel(cbPos(1)-bs2(1):cbPos(1)+bs2(1)), ...
%         numel(cbPos(2) + floor( cradius.*0.5 ) - bs2(2) :cbPos(2) + floor( cradius.*0.5 ) + bs2(2)  )]

%     c1 = cbPos(2)
%     f1 = floor( cradius.*0.5 )
%     ngbs2 = -bs2(2)
    if( isodd( bs2(2) ) )
        fresFilt( cbPos(1)-bs2(1):cbPos(1)+bs2(1), ...
            cbPos(2) + floor( cradius.*0.5 ) - bs2(2) :cbPos(2) + floor( cradius.*0.5 ) + bs2(2) ) = butter;
        fresFilt( cbPos(1)-bs2(1):cbPos(1)+bs2(1), ...
            cbPos(2) - floor( cradius.*0.5 ) - bs2(2) :cbPos(2) - floor( cradius.*0.5 ) + bs2(2) ) = fliplr(butter);
    else % iseven     
        fresFilt( cbPos(1)-bs2(1):cbPos(1)+bs2(1), ...
            cbPos(2) + floor( cradius.*0.5 ) - bs2(2) :cbPos(2) + floor( cradius.*0.5 ) + bs2(2) ) = butter;
        fresFilt( cbPos(1)-bs2(1):cbPos(1)+bs2(1), ...
            cbPos(2) - floor( cradius.*0.5 ) - bs2(2) :cbPos(2) - floor( cradius.*0.5 ) + bs2(2) ) = fliplr(butter);
%         fresFilt( cbPos(1)-bs2(1):cbPos(1)+bs2(1), ...
%             cbPos(2) + floor( cradius.*0.5 ) - bs2(2) + 1 :cbPos(2) + floor( cradius.*0.5 ) + bs2(2) ) = butter;
%         fresFilt( cbPos(1)-bs2(1):cbPos(1)+bs2(1), ...
%             cbPos(2) - floor( cradius.*0.5 ) - bs2(2) + 1 :cbPos(2) - floor( cradius.*0.5 ) + bs2(2) ) = fliplr(butter);
    end
    fresFilt = imrotate( fresFilt, -theta.*180./pi, 'bilinear', 'crop' );

    % Rotation and translation of sideband to zero:
    % This preserves the phase of the original FFT_holo
    fftHolo = (fftHolo .* (1 - fresFilt)) + (fftBackground.*fresFilt);
    % fft_filt = (abs(fft_holo)) .* (1 - fresfilt) + (fft_background.*fresfilt).*exp(1i.*angle(fft_holo));
end
    
if( hp.doSide )
    % Crop sideband to limits of hard aperture function
    sidebandApod = fftHolo(hp.sbPos(1)-radApod:hp.sbPos(1)+radApod-1,hp.sbPos(2)-radApod:hp.sbPos(2)+radApod-1);

    ssize = size(sidebandApod);
    if( isempty( hp.reconSize ) )
        hp.reconSize = ssize;
    end;

    % Apply new apodization filter to the shifted sideband
    % Currently no capacity for soft filters.
    apod = apodization( hp.filtName, ssize ); 

    % Apply apodization
    sidebandApod = sidebandApod .* apod;

    if( hp.reconSize > ssize )
        sidebandApod = padarray( sidebandApod, (hp.reconSize-ssize)./2 );
    end;

    hc.side = ifft2(ifftshift(sidebandApod));
end

reconHolo_out = hc.side; % FIX ME: May be null
sbPos_out = hp.sbPos;

%% Centerband reconstruction
if( hp.doCenter )
    % Apply apod over the centerband
    centerbandApod = fftHolo(cbPos(1)-radApod:cbPos(1)+radApod-1,cbPos(2)-radApod:cbPos(2)+radApod-1);
    
    ssize = size(centerbandApod);
    if( isempty( hp.reconSize ) )
        hp.reconSize = ssize;
    end;
    if( ~exist( 'apod' ) )
        apod = apodization( hp.filtName, ssize ); 
    end
    
    centerbandApod = centerbandApod .* apod;
    
    if( hp.reconSize > ssize )
        centerbandApod = padarray( centerbandApod, (hp.reconSize-ssize)./2 );
    end;
    
    hc.center = abs(ifft2(ifftshift(centerbandApod)));
end

if( hp.doVismap )
    % Apply a rectangular hamming window over the hologram to reduce streaking
    % in reciprocal space.
    hammingApod = apodization( hp.vmApodName , hp.holoSize );
    
    fftHoloHamming = fftshift( fft2( hc.holo .* hammingApod ) );
    
    % REMEMBER THAT THE CENTERBAND IS AT HSIZE2 + 1
    centerbandApodHamming = fftHoloHamming(cbPos(2)-radApod:cbPos(2)+radApod-1, cbPos(1)-radApod:cbPos(1)+radApod-1);
    ssize = size(centerbandApodHamming);
    sidebandApodHamming = fftHoloHamming(hp.sbPos(1)-radApod:hp.sbPos(1)+radApod-1,hp.sbPos(2)-radApod:hp.sbPos(2)+radApod-1);
    
    % DO BANDWIDTH BEFORE APPLICATION OF THE VON HANN FILTER
    if( hp.doBandWidth )
        % Take rotational averages of the sideband and centerband
        rotSide = rotmean( abs( sidebandApodHamming ) );
        rotCenter = rotmean( abs( centerbandApodHamming ) );
        % Normalize
        % rotSide = rotSide ./ rotSide(1); 
        % rotCenter = rotCenter ./ rotCenter(1);
        % Crop
        hc.bandSide = rotSide(1:ssize(1)/2);
        hc.bandCenter = rotCenter(1:ssize(1)/2);
        
        raxis = (1:numel(hc.bandSide) ); % For curve fitting, radius has to start at 1
        
        % To weight, we will find to where the band drops to 0.01 of the
        % max
        bwSide = find( hc.bandSide  < 0.03 .* max(hc.bandSide), 1, 'first' );
        bwCenter = find(hc.bandCenter < 0.03 .* max(hc.bandCenter), 1, 'first' );
        disp( [ 'FFTReconMulti: sideband falls to 3 % power ', ...
            num2str(bwSide), ' pix, centerband at ', num2str(bwCenter), ' pix' ] )
        
        % weightsSide = zeros( size( rotSide ) );
        % weightsSide(1:floor(max( [hc.bandSide*2,length(rotSide)] ))) = 1;
        % weightsCenter = zeros( size( rotCenter ) );
        % weightsCenter(1:floor(max( [hc.bandCenter*2,length(rotCenter)] ))) = 1;
        
        % ft_decay = fittype( 'exp(-x*b) + c' );
        
        % Fit exponential decay functions to the rotational avaerage of the
        % sideband and centerband
        % fitSide = fit( raxis.', rotSide, ft_decay, 'Robust', 'On',  'Weights', weightsSide, 'StartPoint', [0.5 0.01], 'Lower', [0 0] );
        % fitCenter = fit( raxis.', rotCenter, ft_decay, 'Robust', 'On',  'Weights', weightsCenter, 'StartPoint', [0.5 0.01], 'Lower', [0 0] );

        % rplot = (1:0.05:raxis(end));
        % Plot them
        % Since the quality of the fits is fairly poor, we will not plot
        % them
        % figure; 
        semilogy( raxis, hc.bandCenter, 'b', raxis, hc.bandSide, 'r', 'LineWidth', 2.5 );
        set( gca, 'FontSize', 16, 'FontWeight', 'Demi', 'FontName', 'Times' );
        ylabel( 'Log of nominal power (a.u.)' );
        xlabel( 'Pixel radius (pix)' );
        xlim( [0 2.*max([bwCenter, bwSide])] );
        % ylim( [1E-4, 1.2] )
        % legend( ['Centerband (b = ', num2str(fitCenter.b), ')' ], ['Sideband (b = ', num2str(fitSide.b), ')'] );
        legend( 'Centerband', 'Sideband' );
        pause( 0.05 );
    end
    
    if( isempty( hp.reconSize ) )
        hp.reconSize = ssize;
    end;
    vmapod = apodization( hp.vmFiltName, ssize );
    
    centerbandApodHamming = centerbandApodHamming .* vmapod;
    if( hp.reconSize > ssize )
        centerbandApodHamming = padarray( centerbandApodHamming, (hp.reconSize-ssize)./2 );
    end;
    
    
    sidebandApodHamming = sidebandApodHamming .* vmapod;
    if( hp.reconSize > ssize )
        sidebandApodHamming = padarray( sidebandApodHamming, (hp.reconSize-ssize)./2 );
    end;
    
    hc.vismap = 2.0.*abs(ifft2( sidebandApodHamming )) ./ abs(ifft2( centerbandApodHamming )); % Multiply by two because we discarded the conjugate
    
    % Crop anything outside of the range [0,1]
    hc.vismap = hc.vismap.*(hc.vismap < 1.0 & hc.vismap > 0.0) + 1.0.*( hc.vismap > 1.0 );
    
    
end

if( hp.doBandWidth && ~hp.doVismap )
    disp( 'FFTReconMulti Error: please call doVismap if calling doBandwidth' );
end

% Hologram Statistics
% Find mean dose within the x-correlation region
if( hp.doHoloStats )
    hc.calcDose();
    
    %                 if( ~exist( 'CB_ref') || isempty( CB_ref ) )
%                 this.vismap = vismap( this.holo, this.reconSize, sbPos, this.a );
%             else
%                 disp( 'Using vismap_obj, may want to add some current density tracking script' )
%                 this.vismap = vismap_obj( this.holo, this.reconSize, sbPos, this.a, CB_ref );
%             end
%             
%             % Also find the mean visibility
%             % Find the histogram
%             [hvis, hx] = hist( reshape( this.vismap, numel(this.vismap), 1), 0:0.01:1 );
% 
%             % Crop out some of the visibility histogram at low counts
%             crophx = find( hx < 0.025, 1, 'last' );
%             if( isempty( crophx) )
%                 crophx = 1;
%             end
%             hx = hx( crophx:end );
%             hvis = hvis( crophx:end );
% 
%             % Fits
% 
%             try
%                 vfit = fit( hx.', hvis.', 'gauss2' );
%                 this.visibility = max( [vfit.b1, vfit.b2] );
%             catch err
%                 this.visibility = 0;
%             end
end

% Final clean-up
if( ~hp.keepRaw )
    hc.holo = [];
end

end