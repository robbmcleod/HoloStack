function out = holoShiftAndCrop(in, relOffset, newSize)

    inFT = fft2(in);
    
    if( ~exist('newSize') || isempty( newSize ) )
        newSize = size( in );
    end
    
    [rows,cols] = size(inFT);
    if( iseven(rows) )
        rowSeq = [0:rows/2-1, -rows/2:-1]; 
    else
        rowSeq = [0:rows/2, -rows/2:-1];
    end
    if( iseven( cols ) )
        colSeq = [0:cols/2-1, -cols/2:-1];
    else
        colSeq = [0:cols/2, -cols/2:-1];
    end
 
    [colGrid,rowGrid] = meshgrid(colSeq,rowSeq);
 
    % %shift done using DFT "shift theorem" to allow subpixel shift
    expon = -2*pi*(relOffset(1).*rowGrid./rows + relOffset(2).*colGrid./cols);
    inFT = inFT .* exp( 1i .* expon );
    
    out = ifft2(inFT);
    
%    reg = circshift(reg,floor(hSet(j).offsetShift) - minOffset);

    %Crop unneeded part of registered image
    out = out(1:newSize(1),1:newSize(2));
end