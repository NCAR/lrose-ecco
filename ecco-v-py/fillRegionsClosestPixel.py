###############################################################################
# Below is a one-to-one translation of your MATLAB f_velTexture into Python,
# using NumPy and SciPy.
# You'll need the scipy package (for erosion, labeling, and k-d-tree)
# and numpy for the array math.
#

import cv2 as cv
import numpy as np
# from scipy.ndimage import binary_erosion, label, generate_binary_structure
# from scipy.spatial import cKDTree

def fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL):
    useIndices = True

#    # 8) mask out eroded areas
#  ??  velText[~VELsmall.astype(bool)] = np.nan
    
    # 9) fill those eroded pixels by nearest-neighbor within each cloud
    # Fill in the regions that were eroded with closest pixel, but only if
    # there is a non-nan pixel in the contiguous cloud
    # MATLAB: bwconncomp:   Find and count connected components in binary image

    # retval, labels = cv.connectedComponents(image[, labels[, connectivity[, ltype]]])
    # retval, labels = cv.connectedComponents(VELmask, connectivity=8)
    # labels = matrix with labels for each index;  how to? need to? convert to pixel list?
    # cloudRegions=bwconncomp(VELmask);  Matlab version

    retval, labels = cv.connectedComponents(VELmask)  # default connectivity = 8
    # retval is the number of components + 1 for the background
    # labels is the input matrix labeled for each component
    cloudRegions = retval

    for ii in range(1,cloudRegions):  # remember, the first [0] index is the background, so start at 1.
        # thisCloud=cloudRegions.PixelIdxList{ii};
        # if sum(~isnan(velText(thisCloud)))>0: 
        if useIndices:   
            # What is this?  AI generated, uses scipy cKDTree
        
            #labeled, ncomp = label(VELmask) # , structure=structure)
            #for lab in range(1, ncomp+1):
            lab = ii
            # get list of locations (row,col) labeled as this cloud
            coords = np.argwhere(labels == lab)   # list of (row, col)
            if coords.size == 0:
                continue
         
            # which already have a value?
            good = ~np.isnan(velText[coords[:,0], coords[:,1]]) # returns bool array: False if Nan

            if not np.any(good):
                continue
         
            pts_good = coords[good] # nonNan ==> [oldR oldC]
            vals_good = velText[pts_good[:,0], pts_good[:,1]]  # not sure about this.  may not be correct
         
            # find the eroded ones to fill
            eroded = ((VELmask[coords[:,0], coords[:,1]] == 1) &
                      (~VELsmall[coords[:,0], coords[:,1]].astype(bool)))
            pts_fill = coords[eroded]  # should equal toFill or [addR addC]
            if pts_fill.size == 0:
                continue
         
            # nearest neighbor lookup
            tree = cKDTree(pts_good)
            _, idx = tree.query(pts_fill, k=1)
            velText[pts_fill[:,0], pts_fill[:,1]] = vals_good[idx]

        else:
            # Replace with closest pixel
            component=ii
            thisArea = np.where(labels==component, velText, np.nan)
            thisMask = np.where(labels==component, VELMask, np.nan)
            smallMask = np.where(labels==component, VELsmall, np.nan)

            # thisArea=nan(size(VEL));
            # thisArea(thisCloud)=velText(thisCloud);
            # nonNan=thisCloud(~isnan(velText(thisCloud)));  # filter cloud indices by condition
            #[oldR oldC]=ind2sub(size(VEL),nonNan); # convert the nonNan indices to (r,c)
            #thisMask=VELmask(thisCloud);
            #smallMask=VELsmall(thisCloud);
            #toFill=thisCloud(thisMask==1 & smallMask==0); # filter cloud indices by condition
            #[addR addC]=ind2sub(size(VEL),toFill);
            #idx = knnsearch([oldR oldC], [addR addC]); # find closest nonNan (r,c)
            #nearest_OldValue=thisArea(sub2ind(size(thisArea), oldR(idx), oldC(idx)));
            #velText(sub2ind(size(velText), addR, addC))=nearest_OldValue;
    
    return velText

