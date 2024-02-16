% Read gpm data and display

close all
clear all

indir1='/scr/rain2/rsfdata/projects/pecan/mdv/gpm/2AKu/';
infile1='2A.GPM.Ku.V8-20180723.20150611-S074218-E091451.007292.V06A.SUB.h5';

indir2='/scr/rain2/rsfdata/projects/pecan/mdv/gpm/2HSLH/';
infile2='2A.GPM.DPR.GPM-SLH.20150611-S074218-E091451.007292.V06B.SUB.h5';

minLat=30;
maxLat=45;
minLon=-110;
maxLon=-90;

altDisp=5; % Horizontal cut altitude (km) for reflectivity and latent heating

%infoFile=h5info([indir,infile]);

%% Load data

% Reflectivity
refl=h5read([indir1,'/',infile1],'/NS/SLV/zFactorCorrected');
refl=flip(refl,1); % Flip so earth ellipsoid (lowest) level is at index 1.
refl(refl<-9.9998e+03)=nan;

% Altitude
altKM=0:0.125:21.875;
altLhKM=0.25:0.25:20;

% Precip type
typePrecip=h5read([indir1,infile1],'/NS/CSF/typePrecip');
typePrecip=double(typePrecip./10000000); % 1=strat, 2=conv, 3=other
typePrecip(typePrecip==0)=nan;

% Lon/lat
lat=h5read([indir1,'/',infile1],'/NS/Latitude');
lat(lat<-9.9998e+03)=nan;
lon=h5read([indir1,'/',infile1],'/NS/Longitude');
lon(lon<-9.9998e+03)=nan;

% Time
year=h5read([indir1,'/',infile1],'/NS/ScanTime/Year');
month=h5read([indir1,'/',infile1],'/NS/ScanTime/Month');
day=h5read([indir1,'/',infile1],'/NS/ScanTime/DayOfMonth');
hour=h5read([indir1,'/',infile1],'/NS/ScanTime/Hour');
minute=h5read([indir1,'/',infile1],'/NS/ScanTime/Minute');
second=h5read([indir1,'/',infile1],'/NS/ScanTime/Second');
mSecond=h5read([indir1,'/',infile1],'/NS/ScanTime/MilliSecond');

time=datetime(year,month,day,hour,minute,second,mSecond);

% Latent heating
latHeat=h5read([indir2,'/',infile2],'/Swath/latentHeating');
latHeat(latHeat<-9.9998e+03)=nan;

%% Subregion

lon(lon<minLon | lon>maxLon | lat<minLat | lat>maxLat)=nan;
lat(lon<minLon | lon>maxLon | lat<minLat | lat>maxLat)=nan;

goodInds=any(~isnan(lon),1);

lonShort=lon(:,goodInds==1);
latShort=lat(:,goodInds==1);
timeShort=time(goodInds==1);
typeShort=typePrecip(:,goodInds==1);
reflShort=refl(:,:,goodInds==1);
latHeatShort=latHeat(:,:,goodInds==1);

%% Plot
close all

figure('Position',[100 100 2000 500],'DefaultAxesFontSize',12)
reflPlot=squeeze(reflShort(find(altKM==altDisp),:,:));
latHeatPlot=squeeze(latHeatShort(find(altLhKM==altDisp),:,:));
latHeatPlot(isnan(reflPlot))=nan;

ax1=subplot(1,3,1);
surf(lonShort,latShort,reflPlot,'edgecolor','none');
view(2)
ax1.Colormap=jet;
colorbar

xlim([minLon maxLon]);
ylim([minLat maxLat]);
xlabel('Longitude')
ylabel('Latitude')
title('Reflectivity (dBZ)')

ax2=subplot(1,3,2);
surf(lonShort,latShort,latHeatPlot,'edgecolor','none');
view(2)
ax2.Colormap=jet;
colorbar

caxis([-5 15]);
xlim([minLon maxLon]);
ylim([minLat maxLat]);
xlabel('Longitude')
ylabel('Latitude')
title('Latent heating (K/hr)')

ax3=subplot(1,3,3);
surf(lonShort,latShort,typeShort,'edgecolor','none');
view(2)
ax3.Colormap=[0,0,1;1,0,0;0,1,0];
caxis([0.5 3.5])
cb=colorbar;
cb.Ticks=[1,2,3];
cb.TickLabels={'Strat','Conv','Other'};

xlim([minLon maxLon]);
ylim([minLat maxLat]);
xlabel('Longitude')
ylabel('Latitude')
title('Rain type')