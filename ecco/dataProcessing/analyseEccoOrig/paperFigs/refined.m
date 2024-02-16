% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

lonBounds1=[-104.5 -100.5];
latBounds1=[40.99 43.01];

latDisp1=[41.7];
lineBounds1=[-104.1 -101.1];
altLim1=19;

indir1=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/new/20150706/'];
infile1='20150706_005839.mdv.cf.nc';

file=[indir1,infile1];

disp(file);

fileTime=datetime(str2num(infile1(1:4)),str2num(infile1(5:6)),str2num(infile1(7:8)),...
    str2num(infile1(10:11)),str2num(infile1(12:13)),str2num(infile1(14:15)));

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

goodlon=find(lon>=lonBounds1(1) & lon<=lonBounds1(2));
goodlat=find(lat>=latBounds1(1) & lat<=latBounds1(2));

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

[minLat latInd]=min(abs(latDisp1-lat));

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
hi=6;

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

ax1=subplot(2,3,1);

hold on
surf(lon,alt,squeeze(in3D.refl(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');

view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([0 55]);
cb1=colorbar;
cb1.Title.String='dBZ';

title(['(a) Reflectivity']);
grid on
box on
ylabel('Altitude above radar (km)');

ax2=subplot(2,3,2);

hold on
surf(lon,alt,squeeze(in3D.part3D(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax2,colmapPart);

title('(b) ECCO-3D echo type');
grid on
box on

ax3=subplot(2,3,3);

hold on
surf(lon,lat,in2D.part2D(:,:)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
colormap(ax3,colmapPart);
cb2=colorbar;
cb2.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb2.TickLabels=categories;

title(['(c) ECCO-COMP echo type']);
%caxis([0 60]);
%ax3.YTick=(35:2:43);

%title(['(a) Reflectivity (dBZ) at ',num2str(alt(altInd)),' km']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
plot(lineBounds1,[latDisp1,latDisp1],'-k','linewidth',2);
ax3.SortMethod = 'childorder';

%%
lonBounds1=[-98 -97];
latBounds1=[42.4 43];

latDisp1=[42.69];
lineBounds1=[-97.85 -97.1];
altLim1=15;

indir1=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/new/20150622/'];
infile1='20150622_095640.mdv.cf.nc';

file=[indir1,infile1];

disp(file);

fileTime=datetime(str2num(infile1(1:4)),str2num(infile1(5:6)),str2num(infile1(7:8)),...
    str2num(infile1(10:11)),str2num(infile1(12:13)),str2num(infile1(14:15)));


%% Read data
lon=ncread(file,'x0');
lat=ncread(file,'y0');
alt=ncread(file,'z1');

in3D=[];
in2D=[];

% 3D
in3D.texture3D=ncread(file,'DbzTexture3D');
in3D.Convectivity3D=ncread(file,'Convectivity3D');
in3D.refl=ncread(file,'Dbz3D');
in3D.part3Din=ncread(file,'EchoType3D');

% 2D
in2D.part2Din=ncread(file,'EchoTypeComp');

%% Cut out sub region

goodlon=find(lon>=lonBounds1(1) & lon<=lonBounds1(2));
goodlat=find(lat>=latBounds1(1) & lat<=latBounds1(2));


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

[minLat latInd]=min(abs(latDisp1-lat));

ax4=subplot(2,3,4);

hold on
surf(lon,alt,squeeze(in3D.refl(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');

view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([0 55]);
ylabel('Altitude above radar (km)');
title(['(d) Reflectivity']);
grid on
box on

ax5=subplot(2,3,5);

hold on
surf(lon,alt,squeeze(in3D.part3D(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax5,colmapPart);

title('(e) ECCO-3D echo type');
grid on
box on

ax6=subplot(2,3,6);

hold on
surf(lon,lat,in2D.part2D(:,:)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
colormap(ax6,colmapPart);

title(['(f) ECCO-COMP echo type']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
plot(lineBounds1,[latDisp1,latDisp1],'-k','linewidth',2);
ax6.SortMethod = 'childorder';

ax1.Position=[0.05 0.58 0.22 0.37];
ax2.Position=[0.35 0.58 0.22 0.37];
ax3.Position=[0.64 0.58 0.23 0.37];

ax4.Position=[0.05 0.08 0.22 0.37];
ax5.Position=[0.35 0.08 0.22 0.37];
ax6.Position=[0.64 0.08 0.23 0.37];

% ax4.Position=[0.05 0.08 0.37 0.37];
% ax5.Position=[0.503 0.08 0.37 0.37];

cb1.Position=[0.28 0.2 0.02 0.6];
cb2.Position=[0.88 0.2 0.02 0.6];

print([figdir,'refined.png'],'-dpng','-r0')

