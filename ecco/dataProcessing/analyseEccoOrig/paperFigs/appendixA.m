% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

lonBounds=[-101.926 -100.079];
latBounds=[40.5 41.907];

indir=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/mrmsPecan/conv_strat/20150614/'];
indir2=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/mrms_single_thresh/20150614/'];
infile='20150614_235039.mdv.cf.nc';

file=[indir,infile];
file2=[indir2,infile];

disp(file);

fileTime=datetime(str2num(infile(1:4)),str2num(infile(5:6)),str2num(infile(7:8)),...
    str2num(infile(10:11)),str2num(infile(12:13)),str2num(infile(14:15)));

%% Read data
lon=ncread(file,'x0');
lat=ncread(file,'y0');

% 2D
in2D.partS2Din=ncread(file2,'Partition2D');
in2D.refl2Din=ncread(file2,'DbzColMax');
in2D.part2Din=ncread(file,'EchoTypeComp');
in2D.conv2Din=ncread(file,'ConvectivityComp');
in2D.vc2Din=ncread(file,'SmallSubclumps');
in2D.gc2Din=ncread(file,'GrownSubclumps');

%% Cut out sub region

goodlon=find(lon>=lonBounds(1) & lon<=lonBounds(2));
goodlat=find(lat>=latBounds(1) & lat<=latBounds(2));

fields2D=fields(in2D);

for ii=1:length(fields2D);
    in2D.(fields2D{ii})=in2D.(fields2D{ii})(goodlon,goodlat);
end

lon=lon(goodlon);
lat=lat(goodlat);

%[lon2d,lat2d] = meshgrid(lon,lat);

%% Reorder partitioning data to -8 to -1

in2D.partS2D=nan(size(in2D.partS2Din));
in2D.partS2D(in2D.partS2Din==14)=-8; % strat low
in2D.partS2D(in2D.partS2Din==16)=-7; % strat mid
in2D.partS2D(in2D.partS2Din==18)=-6; % strat high
in2D.partS2D(in2D.partS2Din==25)=-5; % mixed
in2D.partS2D(in2D.partS2Din==32)=-4; % conv elevated
in2D.partS2D(in2D.partS2Din==34)=-3; % conv shallow
in2D.partS2D(in2D.partS2Din==36)=-2; % conv mid
in2D.partS2D(in2D.partS2Din==38)=-1; % conv deep

in2D.part2D=nan(size(in2D.part2Din));
in2D.part2D(in2D.part2Din==14)=-8; % strat low
in2D.part2D(in2D.part2Din==16)=-7; % strat mid
in2D.part2D(in2D.part2Din==18)=-6; % strat high
in2D.part2D(in2D.part2Din==25)=-5; % mixed
in2D.part2D(in2D.part2Din==32)=-4; % conv elevated
in2D.part2D(in2D.part2Din==34)=-3; % conv shallow
in2D.part2D(in2D.part2Din==36)=-2; % conv mid
in2D.part2D(in2D.part2Din==38)=-1; % conv deep

in2D.conv2Din(in2D.conv2Din>=0.65)=3;
in2D.conv2Din(in2D.conv2Din>=0.5 & in2D.conv2Din<0.65)=2;
in2D.conv2Din(in2D.conv2Din<0.5)=1;

in2D.vc2Din(in2D.vc2Din>0)=1;
CC1=bwconncomp(in2D.vc2Din);
L1=labelmatrix(CC1);
L1=im2double(L1);
L1(L1==0)=nan;

in1=zeros(size(in2D.gc2Din));
in1(in2D.gc2Din==1)=1;
CCa=bwconncomp(in1);
La=labelmatrix(CCa);
La=im2double(La);

in2=zeros(size(in2D.gc2Din));
in2(in2D.gc2Din==2)=1;
CCb=bwconncomp(in2);
Lb=labelmatrix(CCb);
Lb=im2double(Lb);
Lb(Lb==0)=nan;

L2=zeros(size(in2D.gc2Din));
L2(La>0.0039 & La<0.004)=1;
L2(La>0.007 & La<0.008)=2;
L2(Lb>0.0039 & Lb<0.004)=3;
L2(Lb>0.007 & Lb<0.008)=4;
L2(in2D.gc2Din==3)=5;

L2(L2==0)=nan;

%% Plot

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

ax2=subplot(3,2,2);

hold on
surf(lon,lat,in2D.refl2Din','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([0 60]);
ax2.YTick=(35:0.5:43);

title(['(b) Reflectivity (dBZ)']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
colorbar

ax1=subplot(3,2,1);

hold on
surf(lon,lat,in2D.conv2Din','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
ax1.Colormap=[0,0,0;1,0,0;1,1,0];
caxis([1 4]);
ax1.YTick=(35:0.5:43);

title(['(a) Convectivity']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax3=subplot(3,2,3);
hold on
surf(lon,lat,L1','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
ax3.Colormap=lines(5);
ax3.YTick=(35:0.5:43);

title(['(c) Small clumps']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax4=subplot(3,2,4);
hold on
surf(lon,lat,L2','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
ax4.Colormap=lines(5);
ax4.YTick=(35:0.5:43);

title(['(d) Grown clumps']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

ax5=subplot(3,2,5);
hold on
surf(lon,lat,in2D.partS2D','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
ax5.Colormap=colmapPart;
ax5.YTick=(35:0.5:43);

title(['(e) Echo type single thresh']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

in2D.part2D(L2==2)=-1;

ax6=subplot(3,2,6);
hold on
surf(lon,lat,in2D.part2D','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 0]);
ax6.Colormap=colmapPart;
ax6.YTick=(35:0.5:43);

title(['(f) Echo type dual thresh']);
grid on
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

cb2=colorbar;
cb2.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb2.TickLabels=categories;

ax1.Position=[0.07 0.72 0.35 0.25];
ax2.Position=[0.49 0.72 0.38 0.25];
ax3.Position=[0.07 0.39 0.35 0.25];
ax4.Position=[0.49 0.39 0.38 0.25];
ax5.Position=[0.07 0.06 0.35 0.25];
ax6.Position=[0.49 0.06 0.38 0.25];

print([figdir,'appendixA.png'],'-dpng','-r0')

