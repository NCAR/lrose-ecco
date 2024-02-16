% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/gitPriv/utils/'));

startDate=datetime(2015,6,11);
endDate=datetime(2015,6,12);

minLat=30;
maxLat=45;
minLon=-110;
maxLon=-90;

saveData=0;
plotIndiv=0;

indir=['/scr/rain2/rsfdata/projects/pecan/mdv/conv_strat/new-30C/'];
indirGPM=['/scr/rain2/rsfdata/projects/pecan/mdv/gpm/2AKu/'];

figdir=['/scr/sci/romatsch/stratConv/compGPM/'];

flistGPM=dir([indirGPM,'*.h5']);

flist=makeFileList(indir,startDate,endDate,'20YYMMDDxhhmmss',1);

%% Dates of GPM files
dateGPM=[];

for ii=1:length(flistGPM)
    fileGPM=flistGPM(ii).name;
    dateGPM=[dateGPM;datetime(str2num(fileGPM(23:26)),str2num(fileGPM(27:28)),str2num(fileGPM(29:30)))];
end

dateInds=find(dateGPM>=startDate & dateGPM<=endDate);

%% Times of grid files
slashesGrid=strfind(flist{1},'/');
lastSlashGrid=slashesGrid(end);
timeGrid=[];

for ii=1:length(flist)
    fileGrid=flist{ii};
    timeGrid=[timeGrid;datetime(str2num(fileGrid(lastSlashGrid+1:lastSlashGrid+4)),str2num(fileGrid(lastSlashGrid+5:lastSlashGrid+6)),...
        str2num(fileGrid(lastSlashGrid+7:lastSlashGrid+8)),str2num(fileGrid(lastSlashGrid+10:lastSlashGrid+11)),...
        str2num(fileGrid(lastSlashGrid+12:lastSlashGrid+13)),str2num(fileGrid(lastSlashGrid+14:lastSlashGrid+15)))];
end

%% Loop through GPM files

typeCountPerType=zeros(3,8);
bbCountPerType=zeros(1,8);
anvilCountPerType=zeros(1,8);
shallowCountPerType=zeros(1,8);

for ii = 1:length(dateInds)
    infile=[flistGPM(dateInds(ii)).folder,'/',flistGPM(dateInds(ii)).name];
    
    disp(infile);
    
    %% Load GPM data
    
    lat=h5read(infile,'/NS/Latitude');
    lat(lat<-9.9998e+03)=nan;
    lon=h5read(infile,'/NS/Longitude');
    lon(lat<-9.9998e+03)=nan;
    
    year=h5read(infile,'/NS/ScanTime/Year');
    month=h5read(infile,'/NS/ScanTime/Month');
    day=h5read(infile,'/NS/ScanTime/DayOfMonth');
    hour=h5read(infile,'/NS/ScanTime/Hour');
    minute=h5read(infile,'/NS/ScanTime/Minute');
    second=h5read(infile,'/NS/ScanTime/Second');
    mSecond=h5read(infile,'/NS/ScanTime/MilliSecond');
    
    typePrecip=h5read(infile,'/NS/CSF/typePrecip');
    typePrecip=double(typePrecip./10000000); % 1=strat, 2=conv, 3=other
    
    bb=h5read(infile,'/NS/CSF/flagBB');
    bb(bb>0)=1;
    bb(bb<1)=0;
    bb=double(bb);
    
    anvil=h5read(infile,'/NS/CSF/flagAnvil');
    anvil(anvil>0)=1;
    anvil(anvil<1)=0;
    anvil=double(anvil);
    
    shallow=h5read(infile,'/NS/CSF/flagShallowRain');
    shallow(shallow>0)=1;
    shallow(shallow<1)=0;
    shallow=double(shallow);
    
    time=datetime(year,month,day,hour,minute,second,mSecond);
    
    lon(lon<minLon | lon>maxLon | lat<minLat | lat>maxLat)=nan;
    lat(lon<minLon | lon>maxLon | lat<minLat | lat>maxLat)=nan;
    
    goodInds=any(~isnan(lon),1);
    
    if sum(goodInds)==0
        disp('No data in area.');
        continue
    end
    
    lonShort=lon(:,goodInds==1);
    latShort=lat(:,goodInds==1);
    timeShort=time(goodInds==1);
    typeShort0=typePrecip(:,goodInds==1);
    typeShort=typeShort0;
    typeShort(typeShort0==0)=nan;
    bbShort0=bb(:,goodInds==1);
    bbShort=bbShort0;
    bbShort(bbShort0==0)=nan;
    anvilShort0=anvil(:,goodInds==1);
    anvilShort=anvilShort0;
    anvilShort(anvilShort0==0)=nan;
    shallowShort0=shallow(:,goodInds==1);
    shallowShort=shallowShort0;
    shallowShort(shallowShort0==0)=nan;
    
    % Find matching radar grid file
    fileTime=timeShort(round(length(timeShort)/2));
    
    timeDiff=abs(etime(datevec(timeGrid),datevec(fileTime)));
    [minDiff minInd]=min(timeDiff);
    
    if minDiff>300
        disp('No matching grid file found.')
        continue
    end
    
    infileGrid=flist{minInd};
    disp(infileGrid);
    
    % Read data
    lonGrid=ncread(infileGrid,'x0');
    latGrid=ncread(infileGrid,'y0');
    
    [lon2d,lat2d] = meshgrid(lonGrid,latGrid);
    
    part2Din=ncread(infileGrid,'Partition2D');
    
    % Reorder partitioning data to -8 to -1
    part2D=nan(size(part2Din));
    part2D(part2Din==14)=-8; % strat low
    part2D(part2Din==16)=-7; % strat mid
    part2D(part2Din==18)=-6; % strat high
    part2D(part2Din==25)=-5; % mixed
    part2D(part2Din==32)=-4; % conv elevated
    part2D(part2Din==34)=-3; % conv shallow
    part2D(part2Din==36)=-2; % conv mid
    part2D(part2Din==38)=-1; % conv deep
    
    part2D=part2D';
    
    edges=-8.5:1:-0.5;
    %% Interpolate GPM data to radar grid
    
    % Add a line with zeros at each side of the swath
    up=1;
    meanLon1=mean(lonShort(1,:),'omitnan');
    meanLonEnd=mean(lonShort(end,:),'omitnan');
    if meanLon1>meanLonEnd
        up=0;
    end
    
    if up
        lonShortPad=cat(1,lonShort(1,:)-0.01,lonShort,lonShort(end,:)+0.01);
        latShortPad=cat(1,latShort(1,:)+0.01,latShort,latShort(end,:)-0.01);
    else
        lonShortPad=cat(1,lonShort(1,:)+0.01,lonShort,lonShort(end,:)-0.01);
        latShortPad=cat(1,latShort(1,:)-0.01,latShort,latShort(end,:)+0.01);
    end
    
    typeShort0Pad=cat(1,zeros(1,size(typeShort0,2)),typeShort0,zeros(1,size(typeShort0,2)));
    bbShort0Pad=cat(1,zeros(1,size(bbShort0,2)),bbShort0,zeros(1,size(bbShort0,2)));
    anvilShort0Pad=cat(1,zeros(1,size(anvilShort0,2)),anvilShort0,zeros(1,size(anvilShort0,2)));
    shallowShort0Pad=cat(1,zeros(1,size(shallowShort0,2)),shallowShort0,zeros(1,size(shallowShort0,2)));
    
    % Prepare GPM for interpolation
    lonLatType=double(cat(2,reshape(lonShortPad,[],1),reshape(latShortPad,[],1),reshape(typeShort0Pad,[],1)));
    lonLatType(any(isnan(lonLatType),2),:)=[];
    lonLatBB=double(cat(2,reshape(lonShortPad,[],1),reshape(latShortPad,[],1),reshape(bbShort0Pad,[],1)));
    lonLatBB(any(isnan(lonLatBB),2),:)=[];
    lonLatAnvil=double(cat(2,reshape(lonShortPad,[],1),reshape(latShortPad,[],1),reshape(anvilShort0Pad,[],1)));
    lonLatAnvil(any(isnan(lonLatAnvil),2),:)=[];
    lonLatShallow=double(cat(2,reshape(lonShortPad,[],1),reshape(latShortPad,[],1),reshape(shallowShort0Pad,[],1)));
    lonLatShallow(any(isnan(lonLatShallow),2),:)=[];
    
    % Cut out piece of radar grid that intercepts with GPM lat/lons to
    % speed up interpolation
    minLonFile=min(min(lonShort));
    maxLonFile=max(max(lonShort));
    minLatFile=min(min(latShort));
    maxLatFile=max(max(latShort));
    
    lonInds=find(lonGrid>=minLonFile & lonGrid<=maxLonFile);
    latInds=find(latGrid>=minLatFile & latGrid<=maxLatFile);
    
    lon2dShort=lon2d(latInds,lonInds);
    lat2dShort=lat2d(latInds,lonInds);
    
    % Interpolate
    disp('Interpolating precip type ...');
    interpTypeShort=griddata(lonLatType(:,1),lonLatType(:,2),lonLatType(:,3),double(lon2dShort),double(lat2dShort),'nearest');
    disp('Interpolating bright band ...');
    interpBBShort=griddata(lonLatBB(:,1),lonLatBB(:,2),lonLatBB(:,3),double(lon2dShort),double(lat2dShort),'nearest');
    disp('Interpolating anvil ...');
    interpAnvilShort=griddata(lonLatAnvil(:,1),lonLatAnvil(:,2),lonLatAnvil(:,3),double(lon2dShort),double(lat2dShort),'nearest');
    disp('Interpolating shallow precip ...');
    interpShallowShort=griddata(lonLatShallow(:,1),lonLatShallow(:,2),lonLatShallow(:,3),double(lon2dShort),double(lat2dShort),'nearest');
    
    interpType=nan(size(lon2d));
    interpType(latInds,lonInds)=interpTypeShort;
    interpType(interpType==0)=nan;
    
    interpBB=nan(size(lon2d));
    interpBB(latInds,lonInds)=interpBBShort;
    interpBB(interpBB==0)=nan;
    
    interpAnvil=nan(size(lon2d));
    interpAnvil(latInds,lonInds)=interpAnvilShort;
    interpAnvil(interpAnvil==0)=nan;
    
    interpShallow=nan(size(lon2d));
    interpShallow(latInds,lonInds)=interpShallowShort;
    interpShallow(interpShallow==0)=nan;
    
    %% Remove data that is not in both data sets
    interpType(isnan(part2D))=nan;
    part2D(isnan(interpType))=nan;
    
    interpBB(isnan(part2D))=nan;
    interpAnvil(isnan(part2D))=nan;
    interpShort(isnan(part2D))=nan;
    
    %% Plot individual files
    if plotIndiv
        close all
        categories={'Strat low','Strat mid','Strat high','Mixed',...
            'Conv elev','Conv shallow','Conv mid','Conv deep'};
        
        colmapPart=[0,0.1,0.6;
            0.38,0.42,0.96;
            0.65,0.74,0.86;
            0.32,0.78,0.59;
            1,0,1;
            1,1,0;
            0.99,0.77,0.22;
            1 0 0];
        edges=-8.5:1:-0.5;
        figure('Position',[100 100 2000 600],'DefaultAxesFontSize',12)
        
        ax1=subplot(1,3,1);
        surf(lonShort,latShort,typeShort,'edgecolor','none');
        view(2)
        ax1.Colormap=[0,0,1;1,0,0;0,1,0];
        caxis([0.5 3.5])
        cb=colorbar;
        cb.Ticks=[1,2,3];
        cb.TickLabels={'Strat','Conv','Other'};
        
        xlim([minLon maxLon]);
        ylim([minLat maxLat]);
        xlabel('Longitude')
        ylabel('Latitude')
        title('Rain type orig')
        
        ax2=subplot(1,3,2);
        surf(lon2d,lat2d,interpType,'edgecolor','none');
        view(2)
        ax2.Colormap=[0,0,1;1,0,0;0,1,0];
        caxis([0.5 3.5])
        cb=colorbar;
        cb.Ticks=[1,2,3];
        cb.TickLabels={'Strat','Conv','Other'};
        
        xlim([minLon maxLon]);
        ylim([minLat maxLat]);
        xlabel('Longitude')
        ylabel('Latitude')
        title('Rain type interp')
        
        ax3=subplot(1,3,3);
        surf(lon2d,lat2d,part2D,'edgecolor','none');
        view(2)
        
        caxis([-8 0]);
        colormap(ax3,colmapPart);
        cb=colorbar;
        cb.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
        cb.TickLabels=cat(2,categories);
        
        xlim([minLon maxLon]);
        ylim([minLat maxLat]);
        xlabel('Longitude')
        ylabel('Latitude')
        title('Rain type grid')
    end
    
    %% Rain type analysis
    % Loop through GPM types
    for jj=1:3
        part2Dtype=part2D(interpType==jj);
        [N,~]=histcounts(part2Dtype,edges);
        typeCountPerType(jj,:)=typeCountPerType(jj,:)+N;
    end
    
    part2Dbb=part2D(interpBB==1);
    [N,~]=histcounts(part2Dbb,edges);
    bbCountPerType=bbCountPerType+N;
    
    part2Danvil=part2D(interpAnvil==1);
    [N,~]=histcounts(part2Danvil,edges);
    anvilCountPerType=anvilCountPerType+N;
    
    part2Dshallow=part2D(interpShallow==1);
    [N,~]=histcounts(part2Dshallow,edges);
    shallowCountPerType=shallowCountPerType+N;
end

%% Plot
categories={'Strat low','Strat mid','Strat high','Mixed',...
    'Conv elev','Conv shallow','Conv mid','Conv deep'};

colmapPart=[0,0.1,0.6;
    0.38,0.42,0.96;
    0.65,0.74,0.86;
    0.32,0.78,0.59;
    1,0,1;
    1,1,0;
    0.99,0.77,0.22;
    1 0 0];

stratPerc=typeCountPerType(1,:)./sum(typeCountPerType(1,:)).*100;
convPerc=typeCountPerType(2,:)./sum(typeCountPerType(2,:)).*100;
otherPerc=typeCountPerType(3,:)./sum(typeCountPerType(3,:)).*100;
bbPerc=bbCountPerType./sum(bbCountPerType).*100;
anvilPerc=anvilCountPerType./sum(anvilCountPerType).*100;
shallowPerc=shallowCountPerType./sum(shallowCountPerType).*100;

close all

figure('Position',[100 100 1000 900],'DefaultAxesFontSize',12)
colormap('jet')

ax1=subplot(3,2,1);
b=bar(stratPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');

ylabel('Percent [%]')
title(['Stratiform: ',num2str(sum(typeCountPerType(1,:))),' GPM pixels']);

ax2=subplot(3,2,2);
b=bar(bbPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');

ylabel('Percent [%]')
title(['Bright band: ',num2str(sum(bbCountPerType)),' GPM pixels']);

ax3=subplot(3,2,3);
b=bar(convPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');

ylabel('Percent [%]')
title(['Convective: ',num2str(sum(typeCountPerType(2,:))),' GPM pixels']);

ax4=subplot(3,2,4);
b=bar(anvilPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');

ylabel('Percent [%]')
title(['Anvil: ',num2str(sum(anvilCountPerType)),' GPM pixels']);

ax5=subplot(3,2,5);
b=bar(otherPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');

ylabel('Percent [%]')
title(['Other: ',num2str(sum(typeCountPerType(3,:))),' GPM pixels']);

ax6=subplot(3,2,6);
b=bar(shallowPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');

ylabel('Percent [%]')
title(['Shallow: ',num2str(sum(shallowCountPerType)),' GPM pixels']);

mtit([datestr(startDate,'yyyy-mm-dd HH:MM'),' to ',datestr(endDate,'yyyy-mm-dd HH:MM')],'fontsize',16,'xoff',0.0,'yoff',0.04,'interpreter','none');

ax1.Position=[0.06 0.76 0.43 0.17];
ax2.Position=[0.56 0.76 0.43 0.17];
ax3.Position=[0.06 0.44 0.43 0.17];
ax4.Position=[0.56 0.44 0.43 0.17];
ax5.Position=[0.06 0.12 0.43 0.17];
ax6.Position=[0.56 0.12 0.43 0.17];

print([figdir,'convStrat_lightning_stats_',...
    datestr(startDate,'yyyymmdd_HHMM'),'_to_',datestr(endDate,'yyyymmdd_HHMM'),'.png'],'-dpng','-r0')

if saveData
save([figdir,'data_',datestr(startDate,'yyyymmdd'),'_to_',datestr(endDate,'yyyymmdd'),'.mat'],...
    'stratPerc','convPerc','otherPerc','typeCountPerType','bbPerc','bbCountPerType','anvilPerc','anvilCountPerType','shallowPerc','shallowCountPerType');
end
