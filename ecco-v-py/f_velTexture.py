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


def f_structural_element(dim):
    """
    Construct a structural element (2D matrix) of fixed size and shape.
    This mimics the Matlab strel('disk',5) 
    OpenCV almost works, with MORPH_ELLIPSE ...
    kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE,(9,9)) # ELLIPSE is closest to Matlab's disk, but it is NOT exactly the same

    Parameters
    ----------
    dim : 2D numpy.ndarray
        Input dimension of 2D array; only one value is accepted, 5
        
    Returns
    -------
    kernel : 2D numpy.ndarray of uint8
    """

    if dim != 5:
        raise Exception('dim', 'must equal 5')
    else:
        # THIS WORKS! and equals Matlab results:
        kernel = np.ones((9,9),np.uint8)
        # set the corners of the kernel to 0's
        kernel[8,:2] = 0
        kernel[8,7:] = 0
        kernel[7,0] = 0
        kernel[7,8] = 0
        kernel[0,:2] = 0
        kernel[0,7:] = 0
        kernel[1,0] = 0
        kernel[1,8] = 0
        return kernel


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

    # kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE,(9,9)) # ELLIPSE is closest to Matlab's disk, but it is NOT exactly the same
    # structure = kernel
    # print("structure")
    # print(structure)

    # not bad to start, but need to make it more general, not so many magic numbers
    # TODO make a wrapper for this  py_imerode(I,SE)
    # VELsmall = np.zeros(1)
    # VELsmall = binary_erosion(VELmask, structure).astype(np.uint8)
    # VELsmall = cv.erode(VELmask,structure,iterations = 1)
    #print("VELsmall: result of binary erosion")
    #print(VELsmall)

    kernel = f_structural_element(5)
#**** 
#THIS WORKS! and equals Matlab results:
#kernel = np.ones((9,9),np.uint8)
## set the corners of the kernel to 0's
 #kernel[8,8] = 0
 #kernel[8,7] = 0
 #kernel[7,8] = 0 ...
    erosion = cv.erode(VELmask,kernel,iterations = 1)
    VELsmall = erosion
    print("VELsmall: result of binary erosion")
    print(VELsmall)
# *** 
    # VELsmall = binary_erosion(VELmask, structure=structure, border_value=0).astype(np.uint8) # this doesn't work
   
    # MATLAB: VEL(VELmask==1 & VELsmall==0)=nan;
    VEL[(VELmask == 1) & (VELsmall == 0)] = np.nan
    print("VEL after and")

    # Calculate velocity texture 
    nrows, ncols = VEL.shape
    velText = np.full((nrows, ncols), np.nan)
   
    # Pad data at start and end
    # MATLAB: velPadded=padarray(VEL,[0 pixRad],nan); 
    velPadded = np.pad(VEL,
                       ((0, 0), (pixRad, pixRad)),
                       mode='constant', constant_values=np.nan)
    # velPadded = np.pad(VEL,((0,0),(pixRad,pixRad)),'constant', constant_values=(np.nan))

    #  *** agrees with Matlab to here ***
    # Fill in areas with no data
    # MATLAB: velPadded=fillmissing(velPadded,'linear',2,'EndValues','nearest');    
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
    
    # Adjust velocity with base value
    velPadded = velPadded - velBase
    # *** agrees with Matlab to here *** velPadded(py) == velPadded(Matlab)

# 1/27/2026 maybe this section is ok ...
# written to pull_out_window.py ------ 
    # Loop through data points in time direction and pull out right window ???
    # working here 1/14/2026 
    secondDim = np.size(velPadded[1])
    for ii in range(secondDim-pixRad*2-1):
        print("ii: ", ii)
        velBlock=velPadded(:,ii:ii+pixRad*2);
        print("velBlock: ", velBlock)
    
        % Calculate and remove slope of reflectivity
        % Calculate fit
        x1=1:np.size(velBlock[1]); # second dimension of velBlock
        X=repmat(x1,size(velBlock,1),1);
    
        sumX=sum(X,2,'omitnan');
        sumY=sum(velBlock,2,'omitnan');
        sumXY=sum((velBlock.*X),2,'omitnan');
        sumX2=sum(X.^2,2,'omitnan');
        sumY2=sum(velBlock.^2,2,'omitnan');
    
        N=size(velBlock,2);
    
        a=(sumY.*sumX2-sumX.*sumXY)./(N.*sumX2-sumX.^2);
        b=(N.*sumXY-sumX.*sumY)./(N.*sumX2-sumX.^2);
    
        newY=a+b.*X;
    
        % Remove slope
        velCorr=velBlock-newY+mean(velBlock,2,'omitnan');
        %velCorr=velBlock-newY;
        velCorr(velCorr<1)=1;
    
        % Calculate texture
        tvel=sqrt(std(velCorr.^2,[],2,'omitnan'));
    
        velText(:,ii)=tvel;
    end
# end pull_out_window.py -----

    # ---- junk from AI ...
#    W = 2*pixRad + 1
#    for ii in range(ncols - 1):  # MATLAB did 1:(ncols-1)
#        block = velPadded[:, ii:ii+W]              # (nrows x W)
#        X = np.tile(np.arange(W), (nrows, 1))      # column positions
#        N = float(W)
#        
#        sumX  = np.nansum(X,   axis=1)
#        sumY  = np.nansum(block, axis=1)
#        sumXY = np.nansum(block*X, axis=1)
#        sumX2 = np.nansum(X**2, axis=1)
#        
#        denom = N*sumX2 - sumX**2
#        a = (sumY*sumX2 - sumX*sumXY) / denom
#        b = (N*sumXY - sumX*sumY) / denom
#        
#        newY = a[:,None] + b[:,None]*X
#        velCorr = block - newY + np.nanmean(block, axis=1)[:,None]
#        velCorr[velCorr < 1] = 1
#        
#        # texture = sqrt(std(velCorr^2))
#        tvel = np.sqrt(np.nanstd(velCorr**2, axis=1))
#        velText[:, ii] = tvel
#    # ---- end junk from AI --- 

#    # 8) mask out eroded areas
    velText[~VELsmall.astype(bool)] = np.nan
    
    # 9) fill those eroded pixels by nearest-neighbor within each cloud
    # Fill in the regions that were eroded with closest pixel, but only if
    # there is a non-nan pixel in the contiguous cloud
    # MATLAB: bwconncomp:   Find and count connected components in binary image

    # retval, labels = cv.connectedComponents(image[, labels[, connectivity[, ltype]]])
    cv.connectedComponents(VELmask, connectivity=8)
    # What is this junk?

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

