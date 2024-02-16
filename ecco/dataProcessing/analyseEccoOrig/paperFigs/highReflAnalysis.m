% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

indir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/highRefl/'];
figdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/paperFigs/'];

thresh='42';

%% Plot conv vs dbz

load([indir,'convectivity_',thresh,'dBZ_20150601_0000_to_20150717_0000.mat']);
load([indir,'dbz_',thresh,'dBZ_20150601_0000_to_20150717_0000.mat']);

lfReflConv=cat(2,dbzAll,convectivityAll);
lfReflConv(any(isnan(lfReflConv),2),:)=[];

centers={42.5:1:floor(max(max(lfReflConv(:,1))))+0.5 0.05:0.1:0.95};

N=hist3(lfReflConv,'Ctrs',centers);
N(N==0)=nan;
N=N';

%%
close all

fig=figure('Position',[200 500 900 800],'DefaultAxesFontSize',12);

tickLocX=0.5:2:50.5;
tickLabelX={'42','44','46','48','50','52','54','56','58',...
    '60','62','64','66','68','70','72','74','76','78','80'};
tickLocY=0.5:1:11.5;
tickLabelY={'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};

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

set(fig1,'color','w');

s1=subplot(1,1,1);

colormap('jet');

imagesc(N,'AlphaData',~isnan(N))
set(gca,'YDir','normal');
set(gca,'Xtick',tickLocX);
set(gca,'Xticklabel',tickLabelX);
set(gca,'Ytick',tickLocY);
set(gca,'Yticklabel',tickLabelY);
xlim([0.5 ceil(max(max(lfReflConv(:,1))))-42])
ylim([0.5 10.5])
colorbar
xlabel('Reflectivity (dBZ)');
ylabel('Convectivity');
title(['Convectivity vs reflectivity of >',thresh,' dBZ echo'])
grid on
box on

print([figdir,'convVSdbz_',thresh,'dBZ.png'],'-dpng','-r0')

%% Plot conv vs dbz

load([indir,'part_',thresh,'dBZ_20150601_0000_to_20150717_0000.mat']);
part3dAll(isnan(part3dAll))=[];

edges=[13,15,17,20,30,33,35,37,39];
[catCounts]=histcounts(part3dAll,edges);

%%
close all

fig=figure('Position',[200 500 900 800],'DefaultAxesFontSize',12);

categories={'Strat low','Strat mid','Strat high','Mixed',...
    'Conv elev','Conv shallow','Conv mid','Conv deep'};

colmapPart=[0,0.1,0.6;
    0.38,0.42,0.96;
    0.65,0.74,0.86;
    0.32,0.78,0.59;
    1,0,1;
    1,1,0;
    0.99,0.77,0.22;
    1 0 0];

tickLocX=0.5:2:50.5;
tickLabelX={'42','44','46','48','50','52','54','56','58',...
    '60','62','64','66','68','70','72','74','76','78','80'};

close all

wi=5;
hi=4;

fig1=figure('DefaultAxesFontSize',11,'DefaultFigurePaperType','<custom>','units','inch','position',[3,100,wi,hi]);
fig1.PaperPositionMode = 'manual';
fig1.PaperUnits = 'inches';
fig1.Units = 'inches';
fig1.PaperPosition = [0, 0, wi, hi];
fig1.PaperSize = [wi, hi];
fig1.Resize = 'off';
fig1.InvertHardcopy = 'off';

set(fig1,'color','w');

s1=subplot(1,1,1);

percOut=catCounts./length(part3dAll).*100;
b=bar(percOut,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
set(gca,'YTick',0:10:100);
for kk = 1:8
    b.CData(kk,:)=colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
%ylim([0,35]);
set(gca, 'YGrid', 'on');

ylabel('Percent of >42 dBZ reflectivities (%)')
%title(['Distribution of >',thresh,' dBZ echo per category']);

box on

s1.Position=[0.11 0.224 0.87 0.75];

print([figdir,'highReflCats_',thresh,'dBZ.png'],'-dpng','-r0')

disp(['Stratiform: ',num2str(sum(percOut(1:3)))]);
disp(['Mixed: ',num2str(sum(percOut(4)))]);
disp(['Convective: ',num2str(sum(percOut(5:8)))]);