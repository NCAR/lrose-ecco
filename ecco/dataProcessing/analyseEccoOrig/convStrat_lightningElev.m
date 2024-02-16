% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/gitPriv/utils/'));

startTime=datetime(2015,6,1,0,0,0);
endTime=datetime(2015,7,17,0,0,0);

% startTime=datetime(2015,6,11,2,0,0);
% endTime=datetime(2015,6,11,2,30,0);

plotIndiv=0;
saveData=1;

indir=['/scr/rain2/rsfdata/projects/pecan/mdv/conv_strat/new-elev/'];
indirL=['/scr/rain2/rsfdata/projects/pecan/mdv/ltg/nldn-5min/'];

figdir=['/scr/sci/romatsch/stratConv/compLightning/'];

flist=makeFileList(indir,startTime,endTime,'20YYMMDDxhhmmss',1);

flistL=makeFileList(indirL,startTime,endTime,'20YYMMDDxhhmmss',1);

% Times of lightning files
slashesL=strfind(flistL{1},'/');
lastSlashL=slashesL(end);
timeL=[];

for ii=1:length(flistL)
    fileL=flistL{ii};
    timeL=[timeL;datetime(str2num(fileL(lastSlashL+1:lastSlashL+4)),str2num(fileL(lastSlashL+5:lastSlashL+6)),...
        str2num(fileL(lastSlashL+7:lastSlashL+8)),str2num(fileL(lastSlashL+10:lastSlashL+11)),...
        str2num(fileL(lastSlashL+12:lastSlashL+13)),str2num(fileL(lastSlashL+14:lastSlashL+15)))];
end

%% Loop through radar files

areaLonLat=[];
timesAll=[];

for ii = 1:length(flist)
    file=flist{ii};
    
    %% Find matching lightning file
    slashes=strfind(file,'/');
    lastSlash=slashes(end);
    
    fileTime=datetime(str2num(file(lastSlash+1:lastSlash+4)),str2num(file(lastSlash+5:lastSlash+6)),...
        str2num(file(lastSlash+7:lastSlash+8)),str2num(file(lastSlash+10:lastSlash+11)),...
        str2num(file(lastSlash+12:lastSlash+13)),str2num(file(lastSlash+14:lastSlash+15)));
    
    timeDiff=abs(etime(datevec(timeL),datevec(fileTime)));
    [minDiff minInd]=min(timeDiff);
    
    if minDiff<300
        
        % Read data
        lon=ncread(file,'x0');
        lat=ncread(file,'y0');
        
        [lon2d,lat2d] = meshgrid(lon,lat);
        
        part2Din=ncread(file,'Partition2D');
        
        % Reorder partitioning data to -8 to -1
        bw=part2Din==32; % conv elevated
       
        if max(max(bw))==0
            continue
        end
        
        %% Lightning data
        
        fileL=flistL{minInd};
        
        % Read data
        lonL=ncread(fileL,'x0');
        latL=ncread(fileL,'y0');
        
        lightningRate=ncread(fileL,'LtgRate');
        
        % Interpolate lightning data to radar grid
        [lonL2d,latL2d] = meshgrid(lonL,latL);
        lightningInterp=interp2(lonL2d,latL2d,lightningRate',lon2d,lat2d);
              
        %% Lightning per category
        lightningRight=lightningInterp';
        lightningRight(bw==0)=nan;
        
        if isnan(max(reshape(lightningRight,1,[]),[],'omitnan'));
            continue
        end
        
        %% Loop through features
        
        disp(fileL);
        disp(file);
        
        feat=bwconncomp(bw);
        bw2=zeros(size(bw));
        
        for jj=1:feat.NumObjects
            lightObj=lightningRight(feat.PixelIdxList{jj});
            if sum(lightObj,'omitnan')>50
                bw2(feat.PixelIdxList{jj})=1;
            end
        end
        
        featStats=regionprops(bw2,'Area','Centroid');
        
        for jj=1:size(featStats,1)
            areaLonLat=cat(1,areaLonLat,cat(2,featStats(jj).Area,lon(round(featStats(jj).Centroid(2))),lat(round(featStats(jj).Centroid(:,1)))));
            timesAll=cat(1,timesAll,fileTime);
        end
        
    end
end

