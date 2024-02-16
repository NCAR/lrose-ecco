% Statistics of ecco output

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

showPlot=1;

indir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/statMats/'];
figdir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/'];

infile='mrmsStats_20220501_to_20220601.mat';
load([indir,infile]);

stringDate=infile(end-23:end-4);

%% Plot

xlims=([min(lon),max(lon)]);
ylims=([min(lat),max(lat)]);

states = shaperead('usastatehi',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

countries = shaperead('landareas',...
    'UseGeoCoords',true,'BoundingBox',[double(xlims(1)-10),double(ylims(1)-10);...
    double(xlims(2)+10),double(ylims(2)+10)]);

cats=fields(echoType2D);

%% Total per category
close all

f1 = figure('Position',[200 500 1000 1250],'DefaultAxesFontSize',12,'visible',showPlot);
t = tiledlayout(4,2,'TileSpacing','tight','Padding','tight');

colormap('jet');

for ii=1:length(cats)
    catTot=sum(echoType2D.(cats{ii}),3);
    countTot=sum(countAll,3);
    catPerc=catTot./countTot*100;
    catPerc(catPerc==0)=nan;

    perc=prctile(catPerc(:),99.9);
    clims=[0,ceil(perc)];

    ax=nexttile(ii);

    h=imagesc(lon,lat,catPerc);
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
print(f1,[figdir,'echoTypeTot_',stringDate,'.png'],'-dpng','-r0');

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