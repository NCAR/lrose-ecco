% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

lonBounds=[-104.01 -95.99];
latBounds=[34.99 43.01];

altDisp=5;

lonDisp=[];
latDisp=[39.44];%39.44
lineBounds=[-102 -97];
altLim=20;

%indir=['/scr/rain2/rsfdata/projects/pecan/mdv/conv_strat/new-30C/20150715/'];
indir=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/new/20150715/'];
infile='20150715_080439.mdv.cf.nc';

file=[indir,infile];

disp(file);

fileTime=datetime(str2num(infile(1:4)),str2num(infile(5:6)),str2num(infile(7:8)),...
    str2num(infile(10:11)),str2num(infile(12:13)),str2num(infile(14:15)));

%% Read data
lon=ncread(file,'x0');
lat=ncread(file,'y0');
alt=ncread(file,'z2');

% 3D
in3D.texture3D=ncread(file,'DbzTexture3D');
in3D.Convectivity3D=ncread(file,'Convectivity3D');
in3D.refl=ncread(file,'Dbz3D');
in3D.part3Din=ncread(file,'EchoType3D');

% 2D
in2D.part2Din=ncread(file,'EchoTypeComp');

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

%% Plot

[minAlt altInd]=min(abs(altDisp-alt));

[minLat latInd]=min(abs(latDisp-lat));

close all

wi=10;
hi=10;

fig1=figure('DefaultAxesFontSize',11,'DefaultFigurePaperType','<custom>','units','inch','position',[3,100,wi,hi]);
fig1.PaperPositionMode = 'manual';
fig1.PaperUnits = 'inches';
fig1.Units = 'inches';
fig1.PaperPosition = [0, 0, wi, hi];
fig1.PaperSize = [wi, hi];
fig1.Resize = 'off';
fig1.InvertHardcopy = 'off';

set(fig1,'color','w');

colormap('jet')

ax1=subplot(3,2,1);

hold on
surf(lon,lat,in3D.refl(:,:,altInd)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 60]);
ax1.YTick=(35:2:43);

title(['(a) Reflectivity (dBZ) at ',num2str(alt(altInd)),' km']);
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
plot(lineBounds,[latDisp,latDisp],'-k','linewidth',2);
ax1.SortMethod = 'childorder';

ax2=subplot(3,2,2);

hold on
surf(lon,alt,squeeze(in3D.refl(:,latInd,:))','edgecolor','none');
xlabel('Longitude (deg)');

view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([0 60]);
cb=colorbar;
cb.Title.String='dBZ';

title(['(b) Reflectivity']);
grid on
ylabel('Altitude above radar (km)');

ax3=subplot(3,2,3);
hot1=hot;
colmapUse=cat(1,jet,flipud(hot1(1:50,:)));
ax3.Colormap=colmapUse;

hold on
surf(lon,lat,in3D.Convectivity3D(:,:,altInd)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 1]);
ax3.YTick=(35:2:43);

title(['(c) TDBZ/Convectivity at ',num2str(alt(altInd)),' km']);
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax4=subplot(3,2,4);
ax4.Colormap=colmapUse;

hold on
surf(lon,alt,squeeze(in3D.Convectivity3D(:,latInd,:))','edgecolor','none');
xlabel('Longitude (deg)');
ylabel('Altitude above radar (km)');

view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([0 1]);

title(['(d) TDBZ/Convectivity']);
grid on

cb=colorbar;
cb.Position=[0.92 0.41 0.02 0.21];
cb2=axes('Position',cb.Position,'color','none');  % add mew axes at same posn
cb2.XAxis.Visible='off'; % hide the x axis of new
cb2.YLim=[0 30];       % alternate scale limits new axis
ylabel(cb,'Convectivity','Rotation',-90,'VerticalAlignment','bottom','FontSize',11)
ylabel(cb2,'Reflectivity texture (dBZ)','Rotation',90,'VerticalAlignment','bottom','FontSize',11)

ax5=subplot(3,2,5);

hold on
surf(lon,lat,in3D.part3D(:,:,altInd)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-6 -3]);
colormap(ax5,[0,0,1;0.32,0.78,0.59;1 0 0]);
ax5.YTick=(35:2:43);

title('(e) Basic echo type');
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax6=subplot(3,2,6);

hold on
surf(lon,alt,squeeze(in3D.part3D(:,latInd,:))','edgecolor','none');
xlabel('Longitude (deg)');
ylabel('Altitude above radar (km)');
view(2)
xlim([lineBounds(1),lineBounds(2)]);
ylim([0,altLim]);
caxis([-6 -3]);
colormap(ax6,[0,0,1;0.32,0.78,0.59;1 0 0]);
cb=colorbar;
cb.Ticks=[-5.5,-4.5,-3.5];
cb.TickLabels=cat(2,{'Stratiform','Mixed','Convective'});

title('(f) Basic echo type');
grid on

ax1.Position=[0.06 0.72 0.35 0.25];
ax2.Position=[0.48 0.72 0.38 0.25];
ax3.Position=[0.06 0.39 0.35 0.25];
ax4.Position=[0.48 0.39 0.38 0.25];
ax5.Position=[0.06 0.06 0.35 0.25];
ax6.Position=[0.48 0.06 0.38 0.25];

print([figdir,'refltext.png'],'-dpng','-r0')

