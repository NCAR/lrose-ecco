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

def f_velTexture(VEL, pixRad, velBase):
    """
    Compute the velocity texture of VEL exactly as in the MATLAB version.
    
    Parameters
    ----------
    VEL : 2D numpy.ndarray
        Input velocity field, with np.nan marking missing data.
    pixRad : int
        Radius of the sliding window (in columns).
    velBase : float
        Value to subtract from VEL before computing texture.
        
    Returns
    -------
    velText : 2D numpy.ndarray
        The computed texture field, same shape as VEL, with np.nan
        in eroded or originally-missing regions.
    """
    # 1) make a mask of valid pixels
    VELmask = np.isfinite(VEL).astype(np.uint8)
    print("VELmask")
    print(VELmask) 
    # 2) erode that mask with a disk (8-connectivity)
    # structure = generate_binary_structure(2, 2)  # 3x3 all-ones = 8-connected

    # center = 4
    # strel_list = [[1 if ((i-center)*(i-center)+(j-center)*(j-center)) < 25 else 0  for j in range(9)] for i in range(9)]
    # strel_matrix = np.asarray(strel_list)

    kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE,(9,9)) # ELLIPSE is closest to Matlab's disk, but it is NOT exactly the same
    structure = kernel
    print("structure")
    print(structure)

    # not bad to start, but need to make it more general, not so many magic numbers
    # TODO make a wrapper for this  py_imerode(I,SE)
    # VELsmall = np.zeros(1)
    # VELsmall = binary_erosion(VELmask, structure).astype(np.uint8)
    VELsmall = cv.erode(VELmask,structure,iterations = 1)
    print("VELsmall: result of binary erosion")
    print(VELsmall)

    # VELsmall = binary_erosion(VELmask, structure=structure, border_value=0).astype(np.uint8)
   
    #print(VELmask)
    #print(VELsmall)
    #return VELsmall

 
    # 3) remove edge outliers
    VEL_clean = VEL.copy()
    VEL_clean[(VELmask == 1) & (~VELsmall)] = np.nan
    print("VEL after and")
    print(VEL_clean)
    
    # 4) prep output
    nrows, ncols = VEL.shape
    velText = np.full((nrows, ncols), np.nan)
    
    # 5) pad columns with nan, then fill missing by linear interp + nearest-end
    velPadded = np.pad(VEL_clean,
                       ((0, 0), (pixRad, pixRad)),
                       mode='constant', constant_values=np.nan)
    
    def _fill_line(row):
        x = np.arange(len(row))
        valid = np.isfinite(row)
        if not valid.any():
            return row
        interp = np.interp(x, x[valid], row[valid])
        first, last = x[valid][0], x[valid][-1]
        interp[:first] = row[valid][0]
        interp[last+1:] = row[valid][-1]
        return interp
    
    velPadded = np.apply_along_axis(_fill_line, axis=1, arr=velPadded)
    
    # 6) subtract base
    velPadded = velPadded - velBase
    
    # 7) sliding-window detrend + texture
    W = 2*pixRad + 1
    for ii in range(ncols - 1):  # MATLAB did 1:(ncols-1)
        block = velPadded[:, ii:ii+W]              # (nrows x W)
        X = np.tile(np.arange(W), (nrows, 1))      # column positions
        N = float(W)
        
        sumX  = np.nansum(X,   axis=1)
        sumY  = np.nansum(block, axis=1)
        sumXY = np.nansum(block*X, axis=1)
        sumX2 = np.nansum(X**2, axis=1)
        
        denom = N*sumX2 - sumX**2
        a = (sumY*sumX2 - sumX*sumXY) / denom
        b = (N*sumXY - sumX*sumY) / denom
        
        newY = a[:,None] + b[:,None]*X
        velCorr = block - newY + np.nanmean(block, axis=1)[:,None]
        velCorr[velCorr < 1] = 1
        
        # texture = sqrt(std(velCorr^2))
        tvel = np.sqrt(np.nanstd(velCorr**2, axis=1))
        velText[:, ii] = tvel
    
    # 8) mask out eroded areas
    velText[~VELsmall.astype(bool)] = np.nan
    
    # 9) fill those eroded pixels by nearest-neighbor within each cloud
    labeled, ncomp = label(VELmask) # , structure=structure)
    for lab in range(1, ncomp+1):
        coords = np.argwhere(labeled == lab)   # list of (row, col)
        if coords.size == 0:
            continue
        
        # which already have a value?
        good = ~np.isnan(velText[coords[:,0], coords[:,1]])
        if not np.any(good):
            continue
        
        pts_good = coords[good]
        vals_good = velText[pts_good[:,0], pts_good[:,1]]
        
        # find the eroded ones to fill
        eroded = ((VELmask[coords[:,0], coords[:,1]] == 1) &
                  (~VELsmall[coords[:,0], coords[:,1]].astype(bool)))
        pts_fill = coords[eroded]
        if pts_fill.size == 0:
            continue
        
        # nearest neighbor lookup
        tree = cKDTree(pts_good)
        _, idx = tree.query(pts_fill, k=1)
        velText[pts_fill[:,0], pts_fill[:,1]] = vals_good[idx]
    
    return velText

######################################################################
# Key points & differences from MATLAB

# We use scipy.ndimage.binary_erosion with an 8-connected structuring
# element to replicate imerode(..., strel('disk',5)).

# Padding and fillmissing are done with a custom _fill_line that does
# 1D linear interpolation plus nearest-end fill
# (vectorized via np.apply_along_axis).

# The sliding window detrending is fully vectorized (all rows at once)
# whenever possible, mirroring your sums and omitted-NaN behavior.

# Connected components via scipy.ndimage.label and nearest-neighbor
# via scipy.spatial.cKDTree stand in for bwconncomp + knnsearch.
