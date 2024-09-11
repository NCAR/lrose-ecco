function classSub=f_classSub(classIn,asl,topo,meltOrig,temp,elev,firstRow)

% 14 strat low
% 16 strat mid
% 18 strat high
% 25 mixed
% 30 conv
% 32 conv elevated
% 34 conv shallow
% 36 conv mid
% 38 conv deep

classSub=nan(size(classIn));

% Loop through convective areas and check if they are near the surface
convMask=zeros(size(classIn));
convMask(classIn==3)=1;

convAreas=bwconncomp(convMask);

% Calculate distance between asl and topo
distAslTopo=asl-topo;

% Minimum altitude for low/mid boundary is 2km
% Minimum altitude for mid/high boundary is 4km
melt=meltOrig;
melt(distAslTopo<2000)=9;
melt(isnan(meltOrig))=nan;
temp(distAslTopo<4000 & temp<-25)=-25;

for ii=1:convAreas.NumObjects
    % Check if next to aircraft
    if ~isempty(elev)
        [row1,col1]=ind2sub(size(classIn),convAreas.PixelIdxList{ii});
        planePix=sum(row1==firstRow); % Number of next to plane pixels
        altDiff=distAslTopo(convAreas.PixelIdxList{ii});
        altPlanePix=altDiff(row1==firstRow);
        colsRowFirst=col1(row1==firstRow);
        elevPlanePix=elev(colsRowFirst);
        altLow=length(find(altPlanePix<500 & elevPlanePix'>0));
        planePix=planePix-altLow;
    else
        planePix=0;
    end

    % Check if near surface
    aslArea=distAslTopo(convAreas.PixelIdxList{ii});
    nearSurfPix=sum(aslArea<500);
    if nearSurfPix==0 % Not near surface: elevated
        % Near plane check
        if planePix>10 & median(elev(col1))>0
            classSub(convAreas.PixelIdxList{ii})=30;
        else
            classSub(convAreas.PixelIdxList{ii})=32;
        end
    else
        % Shallow, mid, or deep
        meltMax=max(melt(convAreas.PixelIdxList{ii}));
        if meltMax<15 % Below melting layer: shallow
            % Near plane check
            if planePix>10
                classSub(convAreas.PixelIdxList{ii})=30;
            else
                classSub(convAreas.PixelIdxList{ii})=34;
            end
        else
            minTemp=min(temp(convAreas.PixelIdxList{ii}));
            if minTemp>=-25 % Below divergence level: mid
                % Near plane check
                if planePix>10
                    classSub(convAreas.PixelIdxList{ii})=30;
                else
                    classSub(convAreas.PixelIdxList{ii})=36;
                end
            else % Deep
                % Near plane check
                if planePix>10 & median(elev(col1))>0
                    classSub(convAreas.PixelIdxList{ii})=30;
                else
                    classSub(convAreas.PixelIdxList{ii})=38;
                end
            end
        end
    end
end

% Stratiform
% Low
classSub(classIn==1 & melt<15)=14;
% Mid
classSub(classIn==1 & melt>15 & temp>=-25)=16;
% High
classSub(classIn==1 & melt>15 & temp<-25)=18;

% Mixed
classSub(classIn==2)=25;
end

