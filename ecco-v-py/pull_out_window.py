
def pull_out_window(velPadded, pixRad):

    # Loop through data points in time direction and pull out right window ???
    # working here 1/14/2026 
    secondDim = np.size(velPadded[1])
    for ii in range(secondDim-pixRad*2-1):
        print("ii: ", ii)
        velBlock=velPadded[:,ii:ii+pixRad*2 +1]  #  +1 for python zero index
        print("velBlock: ", velBlock)
    
        # Calculate and remove slope of reflectivity
        # Calculate fit
        x1=np.arange(1,velBlock.shape[1]+1) # second dimension of velBlock; this is constant, set outside of loop
        # x1=1:velBlock.shape[1] # second dimension of velBlock; this is constant, set outside of loop
        # X=repmat(x1,size(velBlock,1),1)
        X=np.tile(x1,(np.shape(velBlock)[0],1))
    
        sumX=np.nansum(X,1)  # sum each row
        sumY=np.nansum(velBlock,1)
        sumXY=np.nansum((velBlock*X),1) 
        sumX2=np.nansum(X*X,1)
        sumY2=np.nansum(velBlock*velBlock,1)
        
        N=np.shape(velBlock)[1]
    
        a=(sumY*sumX2-sumX*sumXY)/(N*sumX2-sumX*sumX)
        b=(N*sumXY-sumX*sumY)/(N*sumX2-sumX*sumX)
    
        #  agrees with Matlab to here. 
        newY=a+b*X
        # do as a list comprehension (a+b)*X_col for every column of X
    
        # Remove slope
        velCorr=velBlock-newY+mean(velBlock,1,'omitnan')
        %velCorr=velBlock-newY
        velCorr(velCorr<1)=1
    
        # Calculate texture
        tvel=sqrt(std(velCorr.^2,[],1,'omitnan'))
    
        velText(:,ii)=tvel
    end
    return velText
