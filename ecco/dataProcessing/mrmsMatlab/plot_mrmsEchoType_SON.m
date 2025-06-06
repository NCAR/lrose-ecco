% Statistics of ecco output

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/mrmsMatlab/'));

showPlot=0;

indir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/ecco_stats/cov80/'];
figdir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/SON/'];

inList={'20210901/20210901_000039.mdv.cf.nc';
    '20211001/20211001_000043.mdv.cf.nc';
    '20211101/20211101_000036.mdv.cf.nc'};

cats={'StratLow','StratMid','StratHigh','Mixed','ConvShallow','ConvMid','ConvDeep','ConvElev'};

loadVars={'CountHourly'};

%maskFile='/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/masks/coverageMasks/coverage_mask20.mat'; % Set to empty for no masking
maskFile=[];

data=loadMRMSmonths(indir,inList,cats,loadVars,maskFile);

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
countTot=sum(data.TotalCount,3);

%% Stratiform mixed, and convective

stratTot=data.StratLow.CountHourly+data.StratMid.CountHourly+data.StratHigh.CountHourly;
convTot=data.ConvShallow.CountHourly+data.ConvMid.CountHourly+data.ConvDeep.CountHourly;

close all

f1 = figure('Position',[200 500 500 1000],'DefaultAxesFontSize',12,'visible','on');
t = tiledlayout(3,1,'TileSpacing','tight','Padding','tight');

colormap('jet');

ax=nexttile(1);

catTot=sum(stratTot,3);
catPerc=catTot./countVal*100;
catPerc(catPerc==0)=nan;

perc=prctile(catPerc(:),99);
clims=[0,perc];

h=imagesc(data.lon,data.lat,catPerc');
set(h, 'AlphaData', ~isnan(h.CData));
set(gca,'YDir','normal');
xlim(xlims);
ylim(ylims);
clim(clims);
cb1=colorbar;
cb1.Title.String='%';

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title('Stratiform');

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

ax=nexttile(2);

catTot=sum(data.Mixed.CountHourly,3);
catPerc=catTot./countVal*100;
catPerc(catPerc==0)=nan;

perc=prctile(catPerc(:),99);
clims=[0,perc];

h=imagesc(data.lon,data.lat,catPerc');
set(h, 'AlphaData', ~isnan(h.CData));
set(gca,'YDir','normal');
xlim(xlims);
ylim(ylims);
clim(clims);
cb1=colorbar;
cb1.Title.String='%';

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title('Mixed');

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

ax=nexttile(3);

catTot=sum(convTot,3);
catPerc=catTot./countVal*100;
catPerc(catPerc==0)=nan;

perc=prctile(catPerc(:),99);
clims=[0,perc];

h=imagesc(data.lon,data.lat,catPerc');
set(h, 'AlphaData', ~isnan(h.CData));
set(gca,'YDir','normal');
xlim(xlims);
ylim(ylims);
clim(clims);
cb1=colorbar;
cb1.Title.String='%';

hold on
geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

title('Convective');

box on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
ax.SortMethod = 'childorder';

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,'stratMixedConv_percentOfValidCounts_SON.png'],'-dpng','-r0');


%% Category percent of total counts
close all

f1 = figure('Position',[200 500 1000 1250],'DefaultAxesFontSize',12,'visible',showPlot);
t = tiledlayout(4,2,'TileSpacing','tight','Padding','tight');

colormap('jet');

for ii=1:length(cats)
    catTot=sum(data.(cats{ii}).CountHourly,3);
    catPerc=catTot./countTot*100;
    catPerc(catPerc==0)=nan;

    perc=prctile(catPerc(:),99);
    clims=[0,perc];

    ax=nexttile(ii);

    h=imagesc(data.lon,data.lat,catPerc');
    set(h, 'AlphaData', ~isnan(h.CData));
    set(gca,'YDir','normal');
    xlim(xlims);
    ylim(ylims);
    if ~all(isnan(catPerc(:)))
        clim(clims);
        cb1=colorbar;
        cb1.Title.String='%';
    end

    hold on
    geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
    geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

    title([cats{ii}]);

    box on
    xlabel('Longitude (deg)');
    ylabel('Latitude (deg)');
    ax.SortMethod = 'childorder';
end

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,'categories_percentOfTotalCounts_SON.png'],'-dpng','-r0');

%% Category percent of valid counts
close all

f1 = figure('Position',[200 500 1000 1250],'DefaultAxesFontSize',12,'visible',showPlot);
t = tiledlayout(4,2,'TileSpacing','tight','Padding','tight');

colormap('jet');

for ii=1:length(cats)
    catTot=sum(data.(cats{ii}).CountHourly,3);
    catPerc=catTot./countVal*100;
    catPerc(catPerc==0)=nan;

    perc=prctile(catPerc(:),99);
    clims=[0,perc];

    ax=nexttile(ii);

    h=imagesc(data.lon,data.lat,catPerc');
    set(h, 'AlphaData', ~isnan(h.CData));
    set(gca,'YDir','normal');
    xlim(xlims);
    ylim(ylims);
    if ~all(isnan(catPerc(:)))
        clim(clims);
        cb1=colorbar;
        cb1.Title.String='%';
    end

    hold on
    geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
    geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

    title([cats{ii}]);

    box on
    xlabel('Longitude (deg)');
    ylabel('Latitude (deg)');
    ax.SortMethod = 'childorder';
end

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,'categories_percentOfValidCounts_SON.png'],'-dpng','-r0');

%% Per hour 0 to 12
for ii=1:length(cats)
    catMat=data.(cats{ii}).CountHourly;
    catPercAll=double(catMat)./countVal*100;
    catPercAll(catPercAll==0)=nan;

    perc=prctile(catPercAll(:),99);
    clims=[0,perc];

    close all

    f1 = figure('Position',[200 500 1600 1250],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    t = tiledlayout(4,3,'TileSpacing','tight','Padding','tight');

    for jj=1:12
        ax=nexttile(jj);

        catPerc=catPercAll(:,:,jj);
        
        if ~isnan(perc)
           
            h=imagesc(data.lon,data.lat,catPerc');
            set(h, 'AlphaData', ~isnan(h.CData));
            set(gca,'YDir','normal');
        end
        xlim(xlims);
        ylim(ylims);
        clim(clims);
        cb1=colorbar;
        cb1.Title.String='%';

        hold on
        geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
        geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

        title([cats{ii},' ',num2str(jj-1),' to ',num2str(jj),' ST']);

        box on
        xlabel('Longitude (deg)');
        ylabel('Latitude (deg)');
        ax.SortMethod = 'childorder';
    end

    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,cats{ii},'_percentOfValidCounts_00-12ST_SON.png'],'-dpng','-r0');

end
% Per hour 12 to 00
for ii=1:length(cats)
    catMat=data.(cats{ii}).CountHourly;
    catPercAll=double(catMat)./countVal*100;
    catPercAll(catPercAll==0)=nan;

    perc=prctile(catPercAll(:),99);
    clims=[0,perc];

    close all

    f1 = figure('Position',[200 500 1600 1250],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    t = tiledlayout(4,3,'TileSpacing','tight','Padding','tight');

    for jj=13:24
        ax=nexttile(jj-12);

        catPerc=catPercAll(:,:,jj);
        
        if ~isnan(perc)
           
            h=imagesc(data.lon,data.lat,catPerc');
            set(h, 'AlphaData', ~isnan(h.CData));
            set(gca,'YDir','normal');
        end
        xlim(xlims);
        ylim(ylims);
        clim(clims);
        cb1=colorbar;
        cb1.Title.String='%';

        hold on
        geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
        geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

        title([cats{ii},' ',num2str(jj-1),' to ',num2str(jj),' ST']);

        box on
        xlabel('Longitude (deg)');
        ylabel('Latitude (deg)');
        ax.SortMethod = 'childorder';
    end

    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,cats{ii},'_percentOfValidCounts_12-00ST_SON.png'],'-dpng','-r0');

end

%% Four times daily
for ii=1:length(cats)
    catMat=data.(cats{ii}).CountHourly;
    catPercAll=double(catMat)./countVal*100;
    catPercAll(catPercAll==0)=nan;

    perc=prctile(catPercAll(:),99);
    clims=[0,perc*6];

    close all

    f1 = figure('Position',[200 500 1000 750],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    t = tiledlayout(2,2,'TileSpacing','tight','Padding','tight');

    inds=[1,6;7,12;13,18;19,24];

    for jj=1:4
        ax=nexttile(jj);

        catPerc=sum(catPercAll(:,:,inds(jj,1):inds(jj,2)),3);
        if ~isnan(perc)
            h=imagesc(data.lon,data.lat,catPerc');
            set(h, 'AlphaData', ~isnan(h.CData));
            set(gca,'YDir','normal');
        end
        xlim(xlims);
        ylim(ylims);
        clim(clims);
        cb1=colorbar;
        cb1.Title.String='%';

        hold on
        geoshow(states,'FaceColor',[1,1,1],'facealpha',0,'DefaultEdgeColor',[0.8,0.8,0.8]);
        geoshow(countries,'FaceColor',[1,1,1],'facealpha',0);

        title([cats{ii},' ',num2str(inds(jj,1)-1),' to ',num2str(inds(jj,2)),' ST']);

        box on
        xlabel('Longitude (deg)');
        ylabel('Latitude (deg)');
        ax.SortMethod = 'childorder';
    end

    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,cats{ii},'_percentOfValidCounts_fourDaily_SON.png'],'-dpng','-r0');

end