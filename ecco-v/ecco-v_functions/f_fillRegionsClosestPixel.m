function velText=f_fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL) 

% Fill in the regions that were eroded with closest pixel, but only if
% there is a non-nan pixel in the contiguous cloud

    cloudRegions=bwconncomp(VELmask);
    
    for ii=1:cloudRegions.NumObjects
        thisCloud=cloudRegions.PixelIdxList{ii};
    
        if sum(~isnan(velText(thisCloud)))>0
            % Replace with closest pixel
             thisArea=nan(size(VEL));
             thisArea(thisCloud)=velText(thisCloud);
             nonNan=thisCloud(~isnan(velText(thisCloud)));
            [oldR oldC]=ind2sub(size(VEL),nonNan);
            thisMask=VELmask(thisCloud);
            smallMask=VELsmall(thisCloud);
            toFill=thisCloud(thisMask==1 & smallMask==0);
            [addR addC]=ind2sub(size(VEL),toFill);
            idx = knnsearch([oldR oldC], [addR addC]);
            nearest_OldValue=thisArea(sub2ind(size(thisArea), oldR(idx), oldC(idx)));
            velText(sub2ind(size(velText), addR, addC))=nearest_OldValue;
        end
    end
    
end
    
