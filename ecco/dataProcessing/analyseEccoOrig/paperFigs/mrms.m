% Find elevated convective and save out list with times

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

lonBounds=[-126.995 -65.995];
latBounds=[23.995 54.995];

basedir=['/scr/sleet1/rsfdata/projects/eolbase/mdv/conv_strat/'];
subdirs={'north_west';
    'north_rockies';
    'north_central';
    'north_east';
    'south_west';
    'south_central';
    'south_east'};
    
infile='20210503_010838.mdv.cf.nc';

readLonBounds=[lonBounds(1),-110.995;
    -110.985,-95.995;
    -95.985,-80.995;
    -80.985,lonBounds(2);
    lonBounds(1),-105.995;
    -105.985,-90.995;
    -90.985,lonBounds(2)];
    
readLatBounds=[38,latBounds(2);
    38,latBounds(2);
    38,latBounds(2);
    38,latBounds(2);
    latBounds(1),39;
    latBounds(1),39;
    latBounds(1),39];

lonBig=lonBounds(1):0.01:lonBounds(2);
latBig=latBounds(1):0.01:latBounds(2);

part2Dbig=single(nan(length(lonBig),length(latBig)));

states = shaperead('usastatehi',...
    'UseGeoCoords',true,'BoundingBox',[double(lonBounds(1)-10),double(latBounds(1)-10);...
    double(lonBounds(2)+10),double(latBounds(2)+10)]);

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(lonBounds(1)-10),double(latBounds(1)-10);...
    double(lonBounds(2)+10),double(latBounds(2)+10)]);

%% Read data

for ii=1:length(subdirs)
    
    file=[basedir,subdirs{ii},'/20210503/',infile];
    
    lon=double(round(ncread(file,'x0'),3));
    lat=round(ncread(file,'y0'),3);
    
    if ii==1
        alt=ncread(file,'z1');
        reflBig=single(nan(length(lonBig),length(latBig),length(alt)));
        part3Dbig=single(nan(length(lonBig),length(latBig),length(alt)));
    end
    
    refl=ncread(file,'Dbz3D');
    part2D=ncread(file,'Partition2D');
    part3D=ncread(file,'Partition3D');
    
    [minX,lonStartIndRead]=min(abs(lon-readLonBounds(ii,1)));
    [minX,lonEndIndRead]=min(abs(lon-readLonBounds(ii,2)));
    [minX,latStartIndRead]=min(abs(lat-readLatBounds(ii,1)));
    [minX,latEndIndRead]=min(abs(lat-readLatBounds(ii,2)));
    
    lonStartIndBig=find(abs(lonBig-lon(lonStartIndRead))<0.0001);
    lonEndIndBig=find(abs(lonBig-lon(lonEndIndRead))<0.0001);
    latStartIndBig=find(abs(latBig-lat(latStartIndRead))<0.0001);
    latEndIndBig=find(abs(latBig-lat(latEndIndRead))<0.0001);
    
    reflBig(lonStartIndBig:lonEndIndBig,latStartIndBig:latEndIndBig,:)=refl(lonStartIndRead:lonEndIndRead,latStartIndRead:latEndIndRead,1:length(alt));
    part3Dbig(lonStartIndBig:lonEndIndBig,latStartIndBig:latEndIndBig,:)=part3D(lonStartIndRead:lonEndIndRead,latStartIndRead:latEndIndRead,1:length(alt));
     part2Dbig(lonStartIndBig:lonEndIndBig,latStartIndBig:latEndIndBig)=part2D(lonStartIndRead:lonEndIndRead,latStartIndRead:latEndIndRead);
end


%% Reorder partitioning data to -8 to -1

part2Dbig(part2Dbig==14)=-8; % strat low
part2Dbig(part2Dbig==16)=-7; % strat mid
part2Dbig(part2Dbig==18)=-6; % strat high
part2Dbig(part2Dbig==25)=-5; % mixed
part2Dbig(part2Dbig==32)=-4; % conv elevated
part2Dbig(part2Dbig==34)=-3; % conv shallow
part2Dbig(part2Dbig==36)=-2; % conv mid
part2Dbig(part2Dbig==38)=-1; % conv deep

part3Dbig(part3Dbig==14)=-8; % strat low
part3Dbig(part3Dbig==16)=-7; % strat mid
part3Dbig(part3Dbig==18)=-6; % strat high
part3Dbig(part3Dbig==25)=-5; % mixed
part3Dbig(part3Dbig==32)=-4; % conv elevated
part3Dbig(part3Dbig==34)=-3; % conv shallow
part3Dbig(part3Dbig==36)=-2; % conv mid
part3Dbig(part3Dbig==38)=-1; % conv deep

%% Plot

latDisp=[37.82];
lineBounds1=[-102.5 -100.3];
altLim1=18;
[minLat latInd]=min(abs(latDisp-latBig));

lonDisp1=[-86.82];
lineBounds2=[34.2 40.8];
altLim2=12;
[minLon1 lonInd1]=min(abs(lonDisp1-lonBig));

lonDisp2=[-113.9];
lineBounds3=[36.92 37.35];
altLim3=14;
[minLon2 lonInd2]=min(abs(lonDisp2-lonBig));

colmapPart=[0,0.1,0.6;
    0.38,0.42,0.96;
    0.65,0.74,0.86;
    0.32,0.78,0.59;
    1,0,1;
    1,1,0;
    0.99,0.77,0.22;
    1 0 0];

categories={'Strat low','Strat mid','Strat high','Mixed',...
    'Conv elev','Conv shallow','Conv mid','Conv deep'};

close all

wi=10;
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

colormap('jet')

ax1=subplot(2,2,1);

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

surf(lonBig,latBig,max(reflBig,[],3)','edgecolor','none');
view(2)
xlim([lonBig(1),lonBig(end)]);
ylim([latBig(1),latBig(end)]);
caxis([0 50]);
cb1=colorbar;
cb1.Title.String='dBZ';

title(['Reflectivity']);

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
plot(lineBounds1,[latDisp,latDisp],'-m','linewidth',2);
plot([lonDisp1,lonDisp1],lineBounds2,'-m','linewidth',2);
plot([lonDisp2,lonDisp2],lineBounds3,'-m','linewidth',2);
ax1.SortMethod = 'childorder';

text(-126.5,53.5,'(a)','Fontsize',11,'FontWeight','bold');

text(-104,38,'A','Fontsize',10,'FontWeight','bold');
text(-100,38,'B','Fontsize',10,'FontWeight','bold');
text(-87.3,33.2,'C','Fontsize',10,'FontWeight','bold');
text(-87.3,41.6,'D','Fontsize',10,'FontWeight','bold');
text(-114.3,36,'E','Fontsize',10,'FontWeight','bold');
text(-114.3,38.5,'F','Fontsize',10,'FontWeight','bold');

ax2=subplot(2,2,3);

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

surf(lonBig,latBig,part2Dbig','edgecolor','none');
view(2)
xlim([lonBig(1),lonBig(end)]);
ylim([latBig(1),latBig(end)]);
caxis([-8 0]);
colormap(ax2,colmapPart);
cb2=colorbar;
cb2.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5];
cb2.TickLabels=categories;

title(['2D Classification']);
box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax2.SortMethod = 'childorder';

text(-126.5,53.5,'(e)','Fontsize',11,'FontWeight','bold');

ax3=subplot(6,3,3);

hold on
surf(lonBig,alt,squeeze(reflBig(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');

view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([0 50]);

grid on
box on
%ylabel('Altitude above radar (km)');
text(-102.45,16.2,'(b)','Fontsize',10,'FontWeight','bold');

text(-102.45,1.5,'A','Fontsize',10,'FontWeight','bold');
text(-100.45,1.5,'B','Fontsize',10,'FontWeight','bold');

ax4=subplot(6,3,6);

hold on
surf(latBig,alt,squeeze(reflBig(lonInd1,:,1:length(alt)))','edgecolor','none');
xlabel('Latitude (deg)');

view(2)
xlim([lineBounds2(1),lineBounds2(2)]);
ylim([0,altLim2]);
caxis([0 50]);

grid on
box on
%ylabel('Altitude above radar (km)');
text(34.4,10.8,'(c)','Fontsize',10,'FontWeight','bold');

text(34.4,1.2,'C','Fontsize',10,'FontWeight','bold');
text(40.2,1.2,'D','Fontsize',10,'FontWeight','bold');

ax5=subplot(6,3,9);

hold on
surf(latBig,alt,squeeze(reflBig(lonInd2,:,1:length(alt)))','edgecolor','none');
xlabel('Latitude (deg)');

view(2)
xlim([lineBounds3(1),lineBounds3(2)]);
ylim([0,altLim3]);
caxis([0 50]);

grid on
box on
%ylabel('Altitude above radar (km)');
text(36.93,12.8,'(d)','Fontsize',10,'FontWeight','bold');

text(36.93,1.2,'E','Fontsize',10,'FontWeight','bold');
text(37.315,1.2,'F','Fontsize',10,'FontWeight','bold');

ax6=subplot(6,3,12);

hold on
surf(lonBig,alt,squeeze(part3Dbig(:,latInd,1:length(alt)))','edgecolor','none');
xlabel('Longitude (deg)');
view(2)
xlim([lineBounds1(1),lineBounds1(2)]);
ylim([0,altLim1]);
caxis([-8 0]);
colormap(ax6,colmapPart);

grid on
box on
text(-102.45,16.2,'(f)','Fontsize',10,'FontWeight','bold');

text(-102.45,1.5,'A','Fontsize',10,'FontWeight','bold');
text(-100.45,1.5,'B','Fontsize',10,'FontWeight','bold');

ax7=subplot(6,3,15);

hold on
surf(latBig,alt,squeeze(part3Dbig(lonInd1,:,1:length(alt)))','edgecolor','none');
xlabel('Latitude (deg)');
view(2)
xlim([lineBounds2(1),lineBounds2(2)]);
ylim([0,altLim2]);
caxis([-8 0]);
colormap(ax7,colmapPart);

grid on
box on
text(34.4,10.8,'(g)','Fontsize',10,'FontWeight','bold');

text(34.4,1.2,'C','Fontsize',10,'FontWeight','bold');
text(40.2,1.2,'D','Fontsize',10,'FontWeight','bold');


ax8=subplot(6,3,18);

hold on
surf(latBig,alt,squeeze(part3Dbig(lonInd2,:,1:length(alt)))','edgecolor','none');
xlabel('Latitude (deg)');
view(2)
xlim([lineBounds3(1),lineBounds3(2)]);
ylim([0,altLim3]);
caxis([-8 0]);
colormap(ax8,colmapPart);

grid on
box on
text(36.93,12.8,'(h)','Fontsize',10,'FontWeight','bold');

text(36.93,1.2,'E','Fontsize',10,'FontWeight','bold');
text(37.315,1.2,'F','Fontsize',10,'FontWeight','bold');

ax1.Position=[0.055 0.555 0.59 0.41];
ax2.Position=[0.055 0.055 0.59 0.41];

ax3.Position=[0.675 0.865 0.2 0.12];
ax4.Position=[0.675 0.7 0.2 0.12];
ax5.Position=[0.675 0.535 0.2 0.12];
ax6.Position=[0.675 0.37 0.2 0.12];
ax7.Position=[0.675 0.205 0.2 0.12];
ax8.Position=[0.675 0.04 0.2 0.12];

cb1.Position=[0.88 0.55 0.02 0.4];
cb2.Position=[0.88 0.065 0.02 0.4];

print([figdir,'mrms.png'],'-dpng','-r0')

