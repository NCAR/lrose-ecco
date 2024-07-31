% Statistics of ecco output

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/mrmsMatlab/'));

showPlot=0;

indir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/mdv/'];
figdir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/masks/coverageMasks/'];

inList={'20210101/20210101_000038.mdv.cf.nc';
    '20220115/20220115_220039.mdv.cf.nc';
    '20220201/20220201_020235.mdv.cf.nc';
    '20230215/20230215_200436.mdv.cf.nc';
    '20230301/20230301_040041.mdv.cf.nc';
    '20210315/20210315_180040.mdv.cf.nc';
    '20210401/20210401_060038.mdv.cf.nc';
    '20220415/20220415_160439.mdv.cf.nc';
    '20220501/20220501_080040.mdv.cf.nc';
    '20230515/20230515_140039.mdv.cf.nc';
    '20230601/20230601_100441.mdv.cf.nc';
    '20210615/20210615_120036.mdv.cf.nc';
    '20210701/20210701_120039.mdv.cf.nc';
    '20220715/20220715_100439.mdv.cf.nc';
    '20220801/20220801_140241.mdv.cf.nc';
    '20230815/20230815_080242.mdv.cf.nc';
    '20230901/20230901_160041.mdv.cf.nc';
    '20210915/20210915_060239.mdv.cf.nc';
    '20211001/20211001_180035.mdv.cf.nc';
    '20221015/20221015_040236.mdv.cf.nc';
    '20221101/20221101_200038.mdv.cf.nc';
    '20231115/20231115_020240.mdv.cf.nc';
    '20231201/20231201_220038.mdv.cf.nc';
    '20211215/20211215_000439.mdv.cf.nc'};

infile1=[indir,inList{1}];
data.lon=ncread(infile1,'x0');
data.lat=ncread(infile1,'y0');

totalCoverage=zeros(length(data.lon)/10,length(data.lat)/10);

%% For plot

xlims=([min(data.lon),max(data.lon)]);
ylims=([min(data.lat),max(data.lat)]);

states = shaperead('usastatehi',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

%% Loop throught files
for ii=1:length(inList)
    infile=[indir,inList{ii}];
    dbzIn=ncread(infile,'DBZ');

    dbzIn=round(dbzIn);
    dbzIn(dbzIn>-95)=-99;

    coverageIn=dbzIn==-99;

    coverage3D=nan(size(coverageIn,1)/10,size(coverageIn,2)/10,size(coverageIn,3));
    for jj=1:size(coverageIn,3)
        coverage3D(:,:,jj)=imresize(coverageIn(:,:,jj),1/10,'nearest');
    end

    sumCoverage=sum(coverage3D,3);
    totalCoverage=totalCoverage+sumCoverage;

    sumCoverage(sumCoverage==0)=nan;

    % Plot
    close all

    f1 = figure('Position',[200 500 600 450],'DefaultAxesFontSize',12,'visible',showPlot);
    t = tiledlayout(1,1,'TileSpacing','tight','Padding','tight');

    colormap(turbo(33));

    ax=nexttile(1);

    clims=[0,33];

    h=imagesc(data.lon,data.lat,sumCoverage');
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

    title('Coverage counts');

    box on
    xlabel('Longitude (deg)');
    ylabel('Latitude (deg)');
    ax.SortMethod = 'childorder';

    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,'coverageCounts_',inList{ii}(1:6),'.png'],'-dpng','-r0');

end

totalCoverage(totalCoverage==0)=nan;
totalCoverage=totalCoverage./length(inList);

%% Plot total

maskValue=25;

close all

f1 = figure('Position',[200 500 500 750],'DefaultAxesFontSize',12,'visible','on');
t = tiledlayout(2,1,'TileSpacing','tight','Padding','tight');

colormap(turbo(33));

ax=nexttile(1);

clims=[0,33];

h=imagesc(data.lon,data.lat,totalCoverage');
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

title('Coverage counts');

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

ax=nexttile(2);

countCovMasked=totalCoverage;
countCovMasked(totalCoverage<maskValue)=nan;

h=imagesc(data.lon,data.lat,countCovMasked');
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

title(['Coverage counts masked at ',num2str(maskValue)]);

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,'coverageCounts_All_mask',num2str(maskValue),'.png'],'-dpng','-r0');

mask=isnan(countCovMasked);
save([figdir,'coverage_mask',num2str(maskValue),'.mat'],'mask')