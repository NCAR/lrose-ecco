function [VELmask, VELsmall, velText] = f_velTexturePre(VEL,pixRad,velBase)

whos
disp('dim of VEL ...');
disp(size(VEL));
disp(VEL);

% Shrink velocity areas to remove outliers at the edges
VELmask=zeros(size(VEL));
VELmask(~isnan(VEL))=1;

disp(VELmask)

VELsmall=imerode(VELmask,strel('disk',5));

disp('VELsmall result of  imerode')
disp(VELsmall)

VEL(VELmask==1 & VELsmall==0)=nan;

disp('VEL after and')
disp(VEL)

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

end

