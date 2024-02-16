% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

xBounds1=[-700 800];
yBounds1=[-1200 300];

lonDisp1=[-33.5];
lineBounds1=[-150 210];
altLim1=19;

indir1=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/opera/conv_strat/20210714/'];
indir2=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/opera/lambert/20210714/'];
infile1='20210714_150500.mdv.cf.nc';

file=[indir1,infile1];
file2=[indir2,infile1];

disp(file);

fileTime=datetime(str2num(infile1(1:4)),str2num(infile1(5:6)),str2num(infile1(7:8)),...
    str2num(infile1(10:11)),str2num(infile1(12:13)),str2num(infile1(14:15)));


%% Read data
lonReal=ncread(file,'lon0');
latReal=ncread(file,'lat0');
lon=ncread(file,'x0');
lat=ncread(file,'y0');

% 2D
in2D.refl=ncread(file2,'DBZ');
in2D.conv=ncread(file,'ConvectivityComp');
in2D.part2Din=ncread(file,'EchoTypeComp');

countries = shaperead('/scr/cirrus1/rsfdata/projects/convstrat/analysis/opera/ne_50m_admin_0_countries.shp',...
    'UseGeoCoords',true,'BoundingBox',[double(min(min(lonReal))-10),double(min(min(latReal))-10);...
    double(max(max(lonReal))+10),double(max(max(latReal))+10)]);

%% Cut out sub region

goodlon=find(lon>=xBounds1(1) & lon<=xBounds1(2));
goodlat=find(lat>=yBounds1(1) & lat<=yBounds1(2));

fields2D=fields(in2D);

for ii=1:length(fields2D);
    in2D.(fields2D{ii})=in2D.(fields2D{ii})(goodlon,goodlat);
end

lon=lon(goodlon);
lat=lat(goodlat);

lonReal=lonReal(goodlon(1):goodlon(end),goodlat(1):goodlat(end));
latReal=latReal(goodlon(1):goodlon(end),goodlat(1):goodlat(end));

%% Reorder partitioning data to -8 to -1

in2D.part2D=nan(size(in2D.part2Din));
in2D.part2D(in2D.part2Din==15)=1; % strat
in2D.part2D(in2D.part2Din==25)=2; % mixed
in2D.part2D(in2D.part2Din==35)=3; % conv

%% Plot

%[minLon lonInd]=min(abs(lonDisp1-lon));

close all

wi=5;
hi=9;

fig1=figure('DefaultAxesFontSize',11,'DefaultFigurePaperType','<custom>','units','inch','position',[3,100,wi,hi]);
fig1.PaperPositionMode = 'manual';
fig1.PaperUnits = 'inches';
fig1.Units = 'inches';
fig1.PaperPosition = [0, 0, wi, hi];
fig1.PaperSize = [wi, hi];
fig1.Resize = 'off';
fig1.InvertHardcopy = 'off';

set(fig1,'color','w');

ax1=subplot(3,1,1);
colormap('jet');
hold on
surf(lonReal',latReal',in2D.refl','edgecolor','none');
view(2)
xlim([min(min(lonReal)),max(max(lonReal))]);
ylim([min(min(latReal)),max(max(latReal))]);
caxis([0 60]);
%ax1.YTick=(35:2:43);
cb1=colorbar;
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title(['(a) Reflectivity (dBZ)']);
grid on
box on
ylabel('Latitude (deg)');

ax3=subplot(3,1,2);
hot1=hot;
colmapUse=cat(1,jet,flipud(hot1(1:50,:)));
ax3.Colormap=colmapUse;

hold on
surf(lonReal',latReal',in2D.conv','edgecolor','none');
view(2)
xlim([min(min(lonReal)),max(max(lonReal))]);
ylim([min(min(latReal)),max(max(latReal))]);
caxis([0 1]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);
%ax3.YTick=(35:2:43);

title(['(b) Convectivity']);
grid on
box on
ylabel('Latitude (deg)');
cb2=colorbar;

ax5=subplot(3,1,3);

hold on
surf(lonReal',latReal',in2D.part2D','edgecolor','none');
view(2)
xlim([min(min(lonReal)),max(max(lonReal))]);
ylim([min(min(latReal)),max(max(latReal))]);
caxis([1 4]);
colormap(ax5,[0,0,1;0.32,0.78,0.59;1 0 0]);
%ax5.YTick=(35:2:43);
cb3=colorbar;
cb3.Ticks=[1.5,2.5,3.5];
cb3.TickLabels=cat(2,{'Stratiform','Mixed','Convective'});
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title('(c) Basic precipitation type');
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax1.Position=[0.11 0.7 0.65 0.26];
ax3.Position=[0.11 0.38 0.65 0.26];
ax5.Position=[0.11 0.06 0.65 0.26];

print([figdir,'opera.png'],'-dpng','-r0')
