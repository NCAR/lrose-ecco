% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

lonBounds1=[-99 -91];
latBounds1=[36.99 44.01];

latDisp1=[41.93];%41.35
lineBounds1=[-96 -93.8];
altLim1=13;

indir1=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/new/20150611/'];
infile1='20150611_082637.mdv.cf.nc';

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

titleLargeXY=[-98.8,43.6];

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

hold on
surf(lon,lat,max(in3D.refl,[],3)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 55]);

%title(['Reflectivity']);
grid on
box on
ax1.YTick=(37:44);
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
plot(lineBounds1,[latDisp1,latDisp1],'-k','linewidth',2);

text(titleLargeXY(1),titleLargeXY(2),'(a) MRMS reflectivity',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

text(-96.4,41.9,'A','Fontsize',11,'fontweight','bold');
text(-93.7,41.9,'B','Fontsize',11,'fontweight','bold');
ax1.SortMethod = 'childorder';

ax2=subplot(4,2,3);

surf(lon,alt,squeeze(in3D.refl(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);

caxis([0 55]);

grid on
box on
ylabel('Altitude (km)');

text(-95.93,11.5,'(c) MRMS reflectivity',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

text(-95.95,1,'A','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
text(-93.9,1,'B','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
ax2.SortMethod = 'childorder';

ax3=subplot(4,2,5);

hold on
surf(lon,lat,in2D.part2D(:,:)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
colormap(ax3,colmapPart);

%title(['2D Classification']);
grid on
box on
%ax3.YTick=(24:26);
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

text(titleLargeXY(1),titleLargeXY(2),'(f) MRMS ECCO-COMP',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');
ax3.SortMethod = 'childorder';

ax4=subplot(4,2,7);

surf(lon,alt,squeeze(in3D.part3D(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax4,colmapPart);

grid on
box on
ylabel('Altitude (km)');

text(-95.93,11.5,'(h) MRMS ECCO-3D',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

text(-95.95,1,'A','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
text(-93.9,1,'B','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
ax4.SortMethod = 'childorder';

%title('3D Classification');
grid on
box on

%% Read GPM

lineBounds1=[-95 -93.8];

indir1=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/conv_strat/20150611/'];
indir2=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/input/20150611/'];
infile1='20150611_081837.mdv.cf.nc';

file=[indir1,infile1];
file2=[indir2,infile1];

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
in2D.part2DorigIn=ncread(file2,'PID');
in2D.part2DorigIn(in2D.part2DorigIn==-1111)=nan;
in2D.part2DorigIn=round(in2D.part2DorigIn./10000000);

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

[minLat latInd]=min(abs(latDisp1-lat));

ax5=subplot(4,2,2);
hold on
surf(lon,lat,max(in3D.refl,[],3)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 55]);

%title(['Reflectivity']);
grid on
box on
%ax1.YTick=(24:26);
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
plot(lineBounds1,[latDisp1,latDisp1],'-k','linewidth',2);

text(titleLargeXY(1),titleLargeXY(2),'(b) GPM reflectivity',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

text(-95.4,41.9,'C','Fontsize',11,'fontweight','bold');
text(-93.7,41.9,'D','Fontsize',11,'fontweight','bold');
ax5.SortMethod = 'childorder';

cb1=colorbar;
cb1.Title.String='dBZ';

ax61=subplot(4,4,7);

surf(lon,alt,squeeze(in3D.refl(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);

caxis([0 55]);

grid on
box on
ylabel('Altitude (km)');

text(-94.94,11.7,'(d) GPM reflectivity',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

text(-94.95,1,'C','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
text(-93.95,1,'D','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
ax61.SortMethod = 'childorder';

ax62=subplot(4,4,8);

surf(lon,alt,squeeze(in3D.part3D(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax62,colmapPart);
ax62.YTickLabel='';

grid on
box on

text(-94.94,11.7,'(e) GPM ECCO-3D',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

text(-94.95,1,'C','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
text(-93.95,1,'D','Fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
ax62.SortMethod = 'childorder';

grid on
box on

ax7=subplot(4,2,6);

hold on
surf(lon,lat,in2D.part2D(:,:)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
colormap(ax7,colmapPart);

%title(['2D Classification']);
grid on
box on
%ax3.YTick=(24:26);
ylabel('Latitude (deg)');

text(titleLargeXY(1),titleLargeXY(2),'(g) GPM ECCO-COMP',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');

ax7.SortMethod = 'childorder';
ax7.XTickLabel='';

cb7=colorbar;
cb7.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb7.TickLabels=categories;

ax8=subplot('Position',[0.49 0.045 0.38 0.23]);

hold on
surf(lon,lat,in2D.part2DorigIn(:,:)','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([1 4]);
colormap(ax8,[0,0,0.9;1 0.5 0;0.32,0.9,0.59]);

%title(['2D Classification']);
grid on
box on
%ax3.YTick=(24:26);
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax8.YTick=37:43;

text(titleLargeXY(1),titleLargeXY(2),'(i) GPM PT',...
    'Fontsize',11,'fontweight','bold','BackgroundColor','w');
ax8.SortMethod = 'childorder';

cb8=colorbar;
cb8.Ticks=[1.5,2.5,3.5];
cb8.TickLabels=cat(2,{'Stratiform','Convective','Other'});

% ax1.Title.Position=[57.5   26.9072   32.2130];
% ax3.Title.Position=[57.5   26.9072   32.2130];
% ax4.Title.Position=[382   19.3110   -4];

ax1.Position=[0.055 0.76 0.38 0.23];
ax2.Position=[0.055 0.555 0.38 0.16];
ax3.Position=[0.055 0.285 0.38 0.23];
ax4.Position=[0.055 0.065 0.38 0.16];

ax5.Position=[0.49 0.76 0.38 0.23];
ax61.Position=[0.49 0.555 0.188 0.16];
ax62.Position=[0.683 0.555 0.188 0.16];
ax7.Position=[0.49 0.285 0.38 0.23];
ax8.Position=[0.49 0.045 0.38 0.23];

cb1.Position=[0.88 0.64 0.02 0.33];
cb7.Position=[0.88 0.3 0.02 0.33];
cb8.Position=[0.88 0.045 0.02 0.23];

print([figdir,'gpmExample.png'],'-dpng','-r0')
