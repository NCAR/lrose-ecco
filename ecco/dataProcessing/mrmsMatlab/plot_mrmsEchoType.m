% Statistics of ecco output

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/mrmsMatlab/'));

showPlot=1;

indir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/ecco_stats/'];
figdir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/'];

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

data=loadMRMSmonths(indir,inList,cats,loadVars);


%% Plot

xlims=([min(data.lon),max(data.lon)]);
ylims=([min(data.lat),max(data.lat)]);

states = shaperead('usastatehi',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);


%% Category percent of total counts
close all

f1 = figure('Position',[200 500 1000 1250],'DefaultAxesFontSize',12,'visible',showPlot);
t = tiledlayout(4,2,'TileSpacing','tight','Padding','tight');

colormap('jet');

for ii=1:length(cats)
    catTot=sum(data.(cats{ii}).Count,3);
    countTot=sum(data.TotalCount,3);
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
    clim(clims);
    cb1=colorbar;
    cb1.Title.String='%';

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
print(f1,[figdir,'categories_percentOfTotalCounts_allMonths.png'],'-dpng','-r0');

%% Category percent of valid counts
close all

f1 = figure('Position',[200 500 1000 1250],'DefaultAxesFontSize',12,'visible',showPlot);
t = tiledlayout(4,2,'TileSpacing','tight','Padding','tight');

colormap('jet');

for ii=1:length(cats)
    catTot=sum(data.(cats{ii}).Count,3);
    countVal=sum(data.ValidCount,3);
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
    clim(clims);
    cb1=colorbar;
    cb1.Title.String='%';

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
print(f1,[figdir,'categories_percentOfValidCounts_allMonths.png'],'-dpng','-r0');

%% Per hour 0 to 12
for ii=1:length(cats)
    catMat=echoType2D.(cats{ii});
    catPercAll=double(catMat)./double(countAll)*100;
    catPercAll(catPercAll==0)=nan;

    close all

    f1 = figure('Position',[200 500 1600 1250],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    t = tiledlayout(4,3,'TileSpacing','tight','Padding','tight');

    for jj=1:12
        ax=nexttile(jj);

        catPerc=catPercAll(:,:,jj);
        perc=prctile(catPerc(:),99.9);
        if ~isnan(perc)
            clims=[0,ceil(perc)];

            h=imagesc(lon,lat,catPerc);
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
    print(f1,[figdir,'echoType_',cats{ii},'_00-12ST_',stringDate,'.png'],'-dpng','-r0');

end
% Per hour 12 to 00
for ii=1:length(cats)
    catMat=echoType2D.(cats{ii});
    catPercAll=double(catMat)./double(countAll)*100;
    catPercAll(catPercAll==0)=nan;

    close all

    f1 = figure('Position',[200 500 1600 1250],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    t = tiledlayout(4,3,'TileSpacing','tight','Padding','tight');

    for jj=13:24
        ax=nexttile(jj-12);

        catPerc=catPercAll(:,:,jj);
        perc=prctile(catPerc(:),99.9);
        if ~isnan(perc)
            clims=[0,ceil(perc)];

            h=imagesc(lon,lat,catPerc);
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
    print(f1,[figdir,'echoType_',cats{ii},'_12-00ST_',stringDate,'.png'],'-dpng','-r0');

end