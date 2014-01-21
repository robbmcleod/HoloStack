function [lambda] = ewavelength( voltage )
% Given an accelerating voltage (defaults to 300 kV), compute the
% relativistic wavelength.

if( nargin == 0 )
    voltage = 3E5;
end

e = 1.60217646E-19; % electron charge
c = 2.99792458E8; % speed of light
m = 9.10938188E-31; % rest electron mass
h = 6.626068E-34; % Planck's constant


E_o = m.*c^2; % rest energy of an electron
E = voltage.*e; % kinetic energy of an electron

% relativistic wavelength, in meters
lambda = h.*c./sqrt( 2.*E.*E_o + E.^2);

