% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

startTime=datetime(2015,6,1,0,0,0);
endTime=datetime(2015,7,17,0,0,0);

% startTime=datetime(2015,6,11,2,0,0);
% endTime=datetime(2015,6,11,2,30,0);

indir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/lightning/'];
figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

%% Load data

load([indir,'exampleData.mat']);
load([indir,'data_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat']);

%% Plot

categories={'Strat low','Strat mid','Strat high','Mixed',...
    'Conv elev','Conv shallow','Conv mid','Conv deep'};

colmapL=gray(20);
colmapPart=[0,0.1,0.6;
    0.38,0.42,0.96;
    0.65,0.74,0.86;
    0.32,0.78,0.59;
    0.8,0,1;
    1,1,0;
    0.99,0.77,0.22;
    1 0 0];
colmap=[colmapPart;colmapL];

close all

wi=10;
hi=7.5;

fig1=figure('DefaultAxesFontSize',11,'DefaultFigurePaperType','<custom>','units','inch','position',[3,100,wi,hi]);
fig1.PaperPositionMode = 'manual';
fig1.PaperUnits = 'inches';
fig1.Units = 'inches';
fig1.PaperPosition = [0, 0, wi, hi];
fig1.PaperSize = [wi, hi];
fig1.Resize = 'off';
fig1.InvertHardcopy = 'off';

formatSpec = '%.2f';

set(fig1,'color','w');

ax1=subplot('Position',[0.055 0.075 0.61 0.5]);

hold on
surf(lon,lat,part2D','edgecolor','none');
view(2)
xlim([lon(1),lon(end)]);
ylim([lat(1),lat(end)]);
caxis([-8 20]);

colormap(ax1,colmap);
scatter(lonlatL(1,:),lonlatL(2,:),1.3,lonlatL(3,:),'o','filled');
title('(d) Classification and flash counts');
grid on
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');

text(-101,33,'Lightning','FontSize',10);

cb=colorbar('location','south');
cb.Position=[0.065 0.09 0.42 0.03];
cb.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5,...
    1,5,10,15,20];
keepLabels = ~cellfun(@isempty,cb.TickLabels);
cb.TickLabels=[];
axCB = axes('Position', cb.Position,...
    'Color', 'none',...
    'xaxisLocation','top',...
    'YTick', [],...
    'XLim', cb.Limits,...
    'XTick', cb.Ticks(keepLabels),...
    'XTickLabel',cat(2,categories,{'1','5','10','15','20'}),...
    'FontSize', 10);
xtickangle(axCB,55);

ax1.SortMethod = 'childorder';

ax2=subplot('Position',[0.055 0.71 0.27 0.25]);
b=bar(areaCatPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
set(gca,'YTick',0:10:100);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,35]);
set(gca, 'YGrid', 'on');

ylabel('Percent of area [%]')
title('(a) Area per echo type category');

ax3=subplot('Position',[0.39 0.71 0.27 0.25]);
b=bar(countPercAll,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
set(gca,'YTick',0:10:100);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,55]);
set(gca, 'YGrid', 'on');

ylabel('Percent of flashes [%]')
title('(b) Flashes per echo type category');

ax4=subplot('Position',[0.72 0.71 0.27 0.25]);
b=bar(lightPerArea,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
set(gca, 'YGrid', 'on');
ylim([0,1.2]);
ylabel('Count/km^2')
title('(c) Flashes per area');

ax5=subplot('Position',[0.72 0.435 0.27 0.14]);
b=bar(numFeatAll,1,'FaceColor','flat');
set(gca,'XTickLabel','');
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
xlim([0.5,4.5]);
ylim([0,5e+5]);
set(gca,'YTick',0:1e+5:5e+5);
set(gca, 'YGrid', 'on');

ylabel('Features')
title('(e) Number of features');

ax6=subplot('Position',[0.72 0.255 0.27 0.14]);
b=bar(lightPerFeat,1,'FaceColor','flat');
set(gca,'XTickLabel','');
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
%xtickangle(45);
xlim([0.5,4.5]);
ylim([0,1100]);
set(gca, 'YGrid', 'on');
set(gca,'YTick',0:200:1200);

ylabel('Flashes/feature')
title('(f) Avg. flashes per feature');

ax7=subplot('Position',[0.72 0.075 0.27 0.14]);
b=bar(percConvWithLA,1,'FaceColor','flat');
set(gca,'XTickLabel',categories(5:8));
set(gca,'YTick',0:20:100);
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
%xtickangle(45);
xlim([0.5,4.5]);
ylim([0,80]);
set(gca, 'YGrid', 'on');
xtickangle(30);

ylabel('Percent of features [%]')
title('(g) Features with lightning');

mtit([datestr(startTime,'yyyy-mm-dd HH:MM'),' to ',datestr(endTime,'yyyy-mm-dd HH:MM')],'fontsize',16,'xoff',0.0,'yoff',0.04,'interpreter','none');

print([figdir,'convStrat_lightning_all_',...
    datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.png'],'-dpng','-r0')
