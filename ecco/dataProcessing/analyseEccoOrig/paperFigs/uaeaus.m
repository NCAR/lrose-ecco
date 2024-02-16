% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

xBounds1=[-400 240];
yBounds1=[-200 240];

lonDisp1=[-33.5];
lineBounds1=[-150 210];
altLim1=19;

indir1=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/uae/conv_strat/20170324/'];
infile1='20170324_033600.mdv.cf.nc';

file=[indir1,infile1];

disp(file);

fileTime=datetime(str2num(infile1(1:4)),str2num(infile1(5:6)),str2num(infile1(7:8)),...
    str2num(infile1(10:11)),str2num(infile1(12:13)),str2num(infile1(14:15)));


%% Read data
lonReal=ncread(file,'lon0');
latReal=ncread(file,'lat0');
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

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(min(min(lonReal))-10),double(min(min(latReal))-10);...
    double(max(max(lonReal))+10),double(max(max(latReal))+10)]);

%% Cut out sub region

goodlon=find(lon>=xBounds1(1) & lon<=xBounds1(2));
goodlat=find(lat>=yBounds1(1) & lat<=yBounds1(2));

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

lonReal=lonReal(goodlon(1):goodlon(end),goodlat(1):goodlat(end));
latReal=latReal(goodlon(1):goodlon(end),goodlat(1):goodlat(end));

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

[minLon lonInd]=min(abs(lonDisp1-lon));

colmapPart=[0,0.1,0.6;
    0.38,0.42,0.96;
    0.65,0.74,0.86;
    0.32,0.78,0.59;
    0.8,0,1;
    1,1,0;
    0.99,0.77,0.22;
    1 0 0];

categories={'Strat low','Strat mid','Strat high','Mixed',...
    'Conv elev','Conv shallow','Conv mid','Conv deep'};

close all

wi=10;
hi=11;

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

ax1=subplot(4,2,1);

geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

hold on
surf(lonReal',latReal',max(in3D.refl,[],3)','edgecolor','none');
view(2)
xlim([lonReal(1,1),lonReal(end,1)]);
ylim([latReal(1,1),latReal(1,end)]);
caxis([0 55]);

title(['UAE                                                  Reflectivity                                    Australia']);
grid on
box on
ax1.YTick=(24:26);
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
x1=find(lon==lonDisp1);
y1=find(lat==lineBounds1(1));
y2=find(lat==lineBounds1(2));
plot([lonReal(x1,y1),lonReal(x1,y1)],[latReal(x1,y1),latReal(x1,y2)],'-k','linewidth',2);

text(51.1,26.6,'(a)','Fontsize',11,'fontweight','bold');

text(54.5,23.3,'A','Fontsize',11,'fontweight','bold');
text(54.3,26.7,'B','Fontsize',11,'fontweight','bold');
ax1.SortMethod = 'childorder';

ax2=subplot(4,2,3);

hold on
surf(lat-lineBounds1(1),alt,squeeze(in3D.refl(lonInd,:,1:length(alt)))','edgecolor','none');
xlabel('Distance (km)');

view(2)
xlim([0,lineBounds1(2)-lineBounds1(1)]);
ylim([0,altLim1]);
caxis([0 55]);

grid on
box on
ylabel('Alt. above radar (km)');

text(10,17,'(c)','Fontsize',11,'fontweight','bold');

text(10,1,'A','Fontsize',11,'fontweight','bold');
text(340,1,'B','Fontsize',11,'fontweight','bold');

ax3=subplot(4,2,5);

hold on

geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

surf(lonReal',latReal',in2D.part2D(:,:)','edgecolor','none');
view(2)
xlim([lonReal(1,1),lonReal(end,1)]);
ylim([latReal(1,1),latReal(1,end)]);
caxis([-8 0]);
colormap(ax3,colmapPart);

title(['2D Precipitation type']);
grid on
box on
ax3.YTick=(24:26);
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

text(51.1,26.6,'(e)','Fontsize',11,'fontweight','bold');
ax3.SortMethod = 'childorder';

ax4=subplot(4,2,7);

hold on
surf(lat-lineBounds1(1),alt,squeeze(in3D.part3D(lonInd,:,1:length(alt)))','edgecolor','none');
xlabel('Distance (km)');
view(2)
xlim([0,lineBounds1(2)-lineBounds1(1)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax4,colmapPart);
ylabel('Alt. above radar (km)');

title('3D Precipitation type');
grid on
box on

text(10,17,'(g)','Fontsize',11,'fontweight','bold');

text(10,1,'A','Fontsize',11,'fontweight','bold');
text(340,1,'B','Fontsize',11,'fontweight','bold');

%% Sidney

yBounds1=[-110 95];
xBounds1=[-220 -10];

lonDisp1=[-61];
lineBounds1=[-90 -10];
altLim1=14;

indir1=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/bom/SydneyMerge/conv_strat/20210313/'];
infile1='20210313_113000.mdv.cf.nc';

file=[indir1,infile1];

disp(file);

fileTime=datetime(str2num(infile1(1:4)),str2num(infile1(5:6)),str2num(infile1(7:8)),...
    str2num(infile1(10:11)),str2num(infile1(12:13)),str2num(infile1(14:15)));

%% Read data
lonReal=ncread(file,'lon0');
latReal=ncread(file,'lat0');
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

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(min(min(lonReal))-10),double(min(min(latReal))-10);...
    double(max(max(lonReal))+10),double(max(max(latReal))+10)]);

%% Cut out sub region

goodlon=find(lon>=xBounds1(1) & lon<=xBounds1(2));
goodlat=find(lat>=yBounds1(1) & lat<=yBounds1(2));

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

lonReal=lonReal(goodlon(1):goodlon(end),goodlat(1):goodlat(end));
latReal=latReal(goodlon(1):goodlon(end),goodlat(1):goodlat(end));

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

[minLon lonInd]=min(abs(lonDisp1-lon));

ax5=subplot(4,2,2);

hold on

surf(lonReal',latReal',max(in3D.refl,[],3)','edgecolor','none');
view(2)
xlim([lonReal(1,1),lonReal(end,1)]);
ylim([latReal(1,1),latReal(1,end)-0.1]);
caxis([0 55]);
cb1=colorbar;
cb1.Title.String='dBZ';
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

grid on
box on
xlabel('Longitude (deg)');
x1=find(round(lon)==lonDisp1);
y1=find(round(lat)==lineBounds1(1));
y2=find(round(lat)==lineBounds1(2));
plot([lonReal(x1,y1(1)),lonReal(x1,y1(1))],[latReal(x1,y1(1)),latReal(x1,y2)],'-k','linewidth',2);

text(148.8,-33.3,'(b)','Fontsize',11,'fontweight','bold');

text(150.4,-34.8,'A','Fontsize',11,'fontweight','bold');
text(150.4,-34.,'B','Fontsize',11,'fontweight','bold');
ax5.SortMethod = 'childorder';

ax6=subplot(4,2,4);

hold on
surf(lat-lineBounds1(1),alt,squeeze(in3D.refl(lonInd,:,1:length(alt)))','edgecolor','none');
xlabel('Distance (km)');

view(2)
xlim([0,lineBounds1(2)-lineBounds1(1)]);
ylim([0,altLim1]);
caxis([0 55]);

grid on
box on

text(2,13,'(d)','Fontsize',11,'fontweight','bold');

text(2,1,'A','Fontsize',11,'fontweight','bold');
text(76,1,'B','Fontsize',11,'fontweight','bold');

ax7=subplot(4,2,6);

hold on
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

surf(lonReal',latReal',in2D.part2D(:,:)','edgecolor','none');
view(2)
xlim([lonReal(1,1),lonReal(end,1)]);
ylim([latReal(1,1),latReal(1,end)-0.1]);
caxis([-8 0]);
colormap(ax7,colmapPart);
cb2=colorbar;
cb2.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb2.TickLabels=categories;

grid on
box on
xlabel('Longitude (deg)');
text(148.8,-33.3,'(f)','Fontsize',11,'fontweight','bold');
ax7.SortMethod = 'childorder';

ax8=subplot(4,2,8);

hold on
surf(lat-lineBounds1(1),alt,squeeze(in3D.part3D(lonInd,:,1:length(alt)))','edgecolor','none');
xlabel('Distance (km)');
view(2)
xlim([0,lineBounds1(2)-lineBounds1(1)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax8,colmapPart);

grid on
box on

text(2,13,'(h)','Fontsize',11,'fontweight','bold');

text(2,1,'A','Fontsize',11,'fontweight','bold');
text(76,1,'B','Fontsize',11,'fontweight','bold');

ax1.Title.Position=[57.5   26.9072   32.2130];
ax3.Title.Position=[57.5   26.9072   32.2130];
ax4.Title.Position=[382   19.3110   -4];

ax1.Position=[0.055 0.745 0.38 0.23];
ax2.Position=[0.055 0.535 0.38 0.16];
ax3.Position=[0.055 0.257 0.38 0.23];
ax4.Position=[0.055 0.045 0.38 0.16];

ax5.Position=[0.49 0.753 0.38 0.214];
ax6.Position=[0.49 0.535 0.38 0.16];
ax7.Position=[0.49 0.257 0.38 0.23];
ax8.Position=[0.49 0.045 0.38 0.16];

cb1.Position=[0.88 0.56 0.02 0.38];
cb2.Position=[0.88 0.07 0.02 0.4];

print([figdir,'uaeaus.png'],'-dpng','-r0')
