function [outmage] = scaletouint16( inmage )
% Scales an arbitrary real matrix with floating point values to the uint16
% range [0 65535];


deltauint16 = 2^16 - 1;

maxin = max(max( inmage ) );
minin = min(min( inmage ) );
deltain = maxin - minin;

% Scale range of 0-65535
outmage = inmage .* deltauint16 ./ deltain;
% Scale min to zero
outmage = uint16( outmage - min(min(outmage)) );
