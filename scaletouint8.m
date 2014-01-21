function [outmage] = scaletouint8( inmage )
% Scales an arbitrary real matrix with floating point values to the uint8
% range [1 256];


deltauint8 = 255;

maxin = max(max( inmage ) );
minin = min(min( inmage ) );
deltain = maxin - minin;

% Scale range of 0-255
outmage = inmage .* (deltauint8 / deltain);
% Scale min to 1.0
outmage = uint8( outmage - min(min(outmage)) + 1 );
