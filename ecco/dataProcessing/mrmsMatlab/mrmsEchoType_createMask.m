% Statistics of ecco output

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/mrmsMatlab/'));

showPlot=1;

indir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/ecco_stats/'];
figdir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/masks/'];

inList={'20210101/20210101_000038.mdv.cf.nc';
    '20210201/20210201_000038.mdv.cf.nc';
    '20210301/20210301_000038.mdv.cf.nc';
    '20210401/20210401_000039.mdv.cf.nc';
    '20210501/20210501_000038.mdv.cf.nc';
    '20210601/20210601_000014.mdv.cf.nc';
    '20210701/20210701_000041.mdv.cf.nc';
    '20210801/20210801_000040.mdv.cf.nc';
    '20210901/20210901_000039.mdv.cf.nc';
    '20211001/20211001_000043.mdv.cf.nc';
    '20211101/20211101_000036.mdv.cf.nc';
    '20211201/20211201_000034.mdv.cf.nc'};

cats={'StratLow','StratMid','StratHigh','Mixed','ConvShallow','ConvMid','ConvDeep','ConvElev'};

loadVars={'Count','Conv'};

maskValue=1000000;

infile1=[indir,inList{1}];
data.lon=ncread(infile1,'x0');
data.lat=ncread(infile1,'y0');

% Loop throught files
for ii=1:length(inList)
    infile=[indir,inList{ii}];
    if ii==1
        data.ValidCount=zeros(length(data.lon),length(data.lat),24);
            end
    data.ValidCount=data.ValidCount+ncread(infile,'ValidCount');
    
end

%% Plot

xlims=([min(data.lon),max(data.lon)]);
ylims=([min(data.lat),max(data.lat)]);

states = shaperead('usastatehi',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

%% Total and valid counts

countVal=sum(data.ValidCount,3);

close all

f1 = figure('Position',[200 500 500 750],'DefaultAxesFontSize',12,'visible',showPlot);
t = tiledlayout(2,1,'TileSpacing','tight','Padding','tight');

colormap('jet');

ax=nexttile(1);

perc=prctile(countVal(:),99);
clims=[0,perc];

h=imagesc(data.lon,data.lat,countVal');
set(h, 'AlphaData', ~isnan(h.CData));
set(gca,'YDir','normal');
xlim(xlims);
ylim(ylims);
clim(clims);
cb1=colorbar;
%cb1.Title.String='Counts';

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title('Valid counts');

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

ax=nexttile(2);

countValMasked=countVal;
countValMasked(countVal<maskValue)=nan;

perc=prctile(countVal(:),99);
clims=[0,perc];

h=imagesc(data.lon,data.lat,countValMasked');
set(h, 'AlphaData', ~isnan(h.CData));
set(gca,'YDir','normal');
xlim(xlims);
ylim(ylims);
clim(clims);
cb1=colorbar;
%cb1.Title.String='Counts';

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title(['Valid counts masked at ',num2str(maskValue)]);

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,'counts_allMonths_mask',num2str(maskValue),'.png'],'-dpng','-r0');

mask=isnan(countValMasked);
save([figdir,'allMonths_mask',num2str(maskValue),'.mat'],'mask')