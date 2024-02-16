% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/gitPriv/utils/'));

lonBounds=[-104 -96];
latBounds=[35 43];

altDisp=5;

lonDisp=[-99.3];
latDisp=[];
lineBounds=[37.5 41.5];
altLim=20;

indir=['/scr/rain2/rsfdata/projects/pecan/mdv/conv_strat/new-30C/20150715/'];
infile='20150715_075837.mdv.cf.nc';

figdir=['/scr/sci/romatsch/stratConv/examples/'];


file=[indir,infile];

disp(file);

fileTime=datetime(str2num(infile(1:4)),str2num(infile(5:6)),str2num(infile(7:8)),...
    str2num(infile(10:11)),str2num(infile(12:13)),str2num(infile(14:15)));

%% Read data
lon=ncread(file,'x0');
lat=ncread(file,'y0');
alt=ncread(file,'z1');

% 3D
in3D.texture3D=ncread(file,'DbzTexture3D');
in3D.Convectivity3D=ncread(file,'Convectivity3D');
in3D.refl=ncread(file,'Dbz3D');
in3D.part3Din=ncread(file,'Partition3D');

% 2D
in2D.part2Din=ncread(file,'Partition2D');

%% Cut out sub region

goodlon=find(lon>=lonBounds(1) & lon<=lonBounds(2));
goodlat=find(lat>=latBounds(1) & lat<=latBounds(2));

fields3D=fields(in3D);
fields2D=fields(in2D);

for ii=1:length(fields3D);
    in3D.(fields3D{ii})=in3D.(fields3D{ii})(goodlon,goodlat,:);
end

for ii=1:length(fields2D);
    in2D.(fields2D{ii})=in2D.(fields2D{ii})(goodlon,goodlat);
end

lon=lon(goodlon);
lat=lat(goodlat);

%[lon2d,lat2d] = meshgrid(lon,lat);

%% Reorder partitioning data to -8 to -1

in2D.part2D=nan(size(in2D.part2Din));
in2D.part2D(in2D.part2Din==14)=-8; % strat low
in2D.part2D(in2D.part2Din==16)=-7; % strat mid
in2D.part2D(in2D.part2Din==18)=-6; % strat high
in2D.part2D(in2D.part2Din==25)=-5; % mixed
in2D.part2D(in2D.part2Din==32)=-4; % conv elevated
in2D.part2D(in2D.part2Din==34)=-3; % conv shallow
in2D.part2D(in2D.part2Din==36)=-2; % conv mid
in2D.part2D(in2D.part2Din==38)=-1; % conv deep

in3D.part3D=nan(size(in3D.part3Din));
in3D.part3D(in3D.part3Din==14)=-8; % strat low
in3D.part3D(in3D.part3Din==16)=-7; % strat mid
in3D.part3D(in3D.part3Din==18)=-6; % strat high
in3D.part3D(in3D.part3Din==25)=-5; % mixed
in3D.part3D(in3D.part3Din==32)=-4; % conv elevated
in3D.part3D(in3D.part3Din==34)=-3; % conv shallow
in3D.part3D(in3D.part3Din==36)=-2; % conv mid
in3D.part3D(in3D.part3Din==38)=-1; % conv deep

%% Plot Horizontal

[minAlt altInd]=min(abs(altDisp-alt));
if ~isnan(lonDisp)
    [minLon lonInd]=min(abs(lonDisp-lon));
else
    [minLat latInd]=min(abs(latDisp-lat));
end

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

close all

figure('Position',[100 100 1300 1000],'DefaultAxesFontSize',12)
colormap('jet')

ax1=subplot(2,2,1);

hold on
surf(lon,lat,in3D.refl(:,:,altInd)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 60]);
cb=colorbar;

title(['Reflectivity (dBZ) at ',num2str(alt(altInd)),' km']);
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

if isempty(lonDisp)
    plot(lineBounds,[latDisp,latDisp],'-k','linewidth',2);
else
    plot([lonDisp,lonDisp],lineBounds,'-k','linewidth',2);
end
ax1.SortMethod = 'childorder';
 
ax2=subplot(2,2,2);

hold on
surf(lon,lat,in3D.Convectivity3D(:,:,altInd)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 1]);
cb=colorbar;

title(['Convectivity at ',num2str(alt(altInd)),' km']);
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

if isempty(lonDisp)
    plot(lineBounds,[latDisp,latDisp],'-k','linewidth',2);
else
    plot([lonDisp,lonDisp],lineBounds,'-k','linewidth',2);
end
ax2.SortMethod = 'childorder';

ax3=subplot(2,2,3);

hold on
surf(lon,lat,in3D.part3D(:,:,altInd)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-6 -3]);
colormap(ax3,[0,0,1;0.32,0.78,0.59;1 0 0]);
cb=colorbar;
cb.Ticks=[-5.5,-4.5,-3.5];
cb.TickLabels=cat(2,{'Stratiform','Mixed','Convective'});

title('3D basic conv/strat partitioning');
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

if isempty(lonDisp)
    plot(lineBounds,[latDisp,latDisp],'-k','linewidth',2);
else
    plot([lonDisp,lonDisp],lineBounds,'-k','linewidth',2);
end
ax3.SortMethod = 'childorder';

ax4=subplot(2,2,4);

hold on
surf(lon,lat,in2D.part2D','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
colormap(ax4,colmapPart);
cb=colorbar;
cb.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb.TickLabels=cat(2,categories);

title('2D conv/strat partitioning');
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

if isempty(lonDisp)
    plot(lineBounds,[latDisp,latDisp],'-k','linewidth',2);
else
    plot([lonDisp,lonDisp],lineBounds,'-k','linewidth',2);
end
ax4.SortMethod = 'childorder';

%mtit(datestr(fileTime,'yyyy-mm-dd HH:MM:SS'),'fontsize',16,'xoff',0.0,'yoff',0.04,'interpreter','none');

print([figdir,'convStrat_hor2_',datestr(fileTime,'yyyymmdd_HHMMSS'),'.png'],'-dpng','-r0')

%% Plot vertical

figure('Position',[100 100 1300 1000],'DefaultAxesFontSize',12)
colormap('jet')

ax1=subplot(2,2,1);

hold on
if isempty(lonDisp)
    surf(lon,alt,squeeze(in3D.refl(:,latInd,:))','edgecolor','none');
    xlabel('Longitude (deg)');
else
    surf(lat,alt,squeeze(in3D.refl(lonInd,:,:))','edgecolor','none');
    xlabel('Latitude (deg)');
end
view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([0 60]);
cb=colorbar;

title(['Reflectivity (dBZ)']);
grid on
ylabel('Altitude above radar (km)');

ax2=subplot(2,2,2);

hold on
if isempty(lonDisp)
    surf(lon,alt,squeeze(in3D.Convectivity3D(:,latInd,:))','edgecolor','none');
    xlabel('Longitude (deg)');
else
    surf(lat,alt,squeeze(in3D.Convectivity3D(lonInd,:,:))','edgecolor','none');
    xlabel('Latitude (deg)');
end
view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([0 1]);
cb=colorbar;

title(['Convectivity']);
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax3=subplot(2,2,3);

hold on
if isempty(lonDisp)
    surf(lon,alt,squeeze(in3D.part3D(:,latInd,:))','edgecolor','none');
    xlabel('Longitude (deg)');
else
    surf(lat,alt,squeeze(in3D.part3D(lonInd,:,:))','edgecolor','none');
    xlabel('Latitude (deg)');
end
view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([-6 -3]);
colormap(ax3,[0,0,1;0.32,0.78,0.59;1 0 0]);
cb=colorbar;
cb.Ticks=[-5.5,-4.5,-3.5];
cb.TickLabels=cat(2,{'Stratiform','Mixed','Convective'});

title('3D basic conv/strat partitioning');
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax4=subplot(2,2,4);

hold on
if isempty(lonDisp)
    surf(lon,alt,squeeze(in3D.part3D(:,latInd,:))','edgecolor','none');
    xlabel('Longitude (deg)');
else
    surf(lat,alt,squeeze(in3D.part3D(lonInd,:,:))','edgecolor','none');
    xlabel('Latitude (deg)');
end
view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([-8 0]);
colormap(ax4,colmapPart);
cb=colorbar;
cb.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb.TickLabels=cat(2,categories);

title('3D conv/strat partitioning');
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');


%mtit(datestr(fileTime,'yyyy-mm-dd HH:MM:SS'),'fontsize',16,'xoff',0.0,'yoff',0.04,'interpreter','none');

print([figdir,'convStrat_ver2_',datestr(fileTime,'yyyymmdd_HHMMSS'),'.png'],'-dpng','-r0')

