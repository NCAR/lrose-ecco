function velText=f_velTexture(VEL,pixRad,velBase)

% Shrink velocity areas to remove outliers at the edges
VELmask=zeros(size(VEL));
VELmask(~isnan(VEL))=1;

VELsmall=imerode(VELmask,strel('disk',5));

VEL(VELmask==1 & VELsmall==0)=nan;

% Calculate velocity texture
velText=nan(size(VEL));

% Pad data at start and end
velPadded=padarray(VEL,[0 pixRad],nan);

% Fill in areas with no data
velPadded=fillmissing(velPadded,'linear',2,'EndValues','nearest');

% Adjust velocity with base value
velPadded=velPadded-velBase;

% Loop through data points in time direction and pull out right window
for ii=1:size(velPadded,2)-pixRad*2-1
    velBlock=velPadded(:,ii:ii+pixRad*2);
        
    % Calculate and remove slope of reflectivity
    % Calculate fit
    x1=1:size(velBlock,2);
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
velText(VELsmall==0)=nan;

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

