
function velText=pullOutWindow(velPadded,pixRad,velText)

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
