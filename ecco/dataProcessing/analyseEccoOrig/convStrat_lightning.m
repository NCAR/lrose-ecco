% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/gitPriv/utils/'));

startTime=datetime(2015,6,1,0,0,0);
endTime=datetime(2015,7,17,0,0,0);

% startTime=datetime(2015,6,11,2,0,0);
% endTime=datetime(2015,6,11,2,30,0);

plotIndiv=0;
saveData=1;

indir=['/scr/cirrus1/rsfdata/projects/pecan/mdv/conv_strat/new/'];
indirL=['/scr/cirrus1/rsfdata/projects/pecan/mdv/ltg/nldn-5min/'];

figdir=['/scr/sci/romatsch/stratConv/compLightning/'];

flist=makeFileList(indir,startTime,endTime,'20YYMMDDxhhmmss',1);

flistL=makeFileList(indirL,startTime,endTime,'20YYMMDDxhhmmss',1);

% Times of lightning files
slashesL=strfind(flistL{1},'/');
lastSlashL=slashesL(end);
timeL=[];

for ii=1:length(flistL)
    fileL=flistL{ii};
    timeL=[timeL;datetime(str2num(fileL(lastSlashL+1:lastSlashL+4)),str2num(fileL(lastSlashL+5:lastSlashL+6)),...
        str2num(fileL(lastSlashL+7:lastSlashL+8)),str2num(fileL(lastSlashL+10:lastSlashL+11)),...
        str2num(fileL(lastSlashL+12:lastSlashL+13)),str2num(fileL(lastSlashL+14:lastSlashL+15)))];
end

%% Loop through radar files

countPerCatAll=zeros(8,1);
lightSumAll=0;
totPixAll=zeros(8,1);
numFeatAll=zeros(4,1);

for ii = 1:length(flist)
    file=flist{ii};
    
    disp(file);
    
    %% Find matching lightning file
    slashes=strfind(file,'/');
    lastSlash=slashes(end);
    
    fileTime=datetime(str2num(file(lastSlash+1:lastSlash+4)),str2num(file(lastSlash+5:lastSlash+6)),...
        str2num(file(lastSlash+7:lastSlash+8)),str2num(file(lastSlash+10:lastSlash+11)),...
        str2num(file(lastSlash+12:lastSlash+13)),str2num(file(lastSlash+14:lastSlash+15)));
    
    timeDiff=abs(etime(datevec(timeL),datevec(fileTime)));
    [minDiff minInd]=min(timeDiff);
    
    if minDiff<300
        
        % Read data
        lon=ncread(file,'x0');
        lat=ncread(file,'y0');
        
        [lon2d,lat2d] = meshgrid(lon,lat);
        
        part2Din=ncread(file,'Partition2D');
        
        % Reorder partitioning data to -8 to -1
        part2D=nan(size(part2Din));
        part2D(part2Din==14)=-8; % strat low
        part2D(part2Din==16)=-7; % strat mid
        part2D(part2Din==18)=-6; % strat high
        part2D(part2Din==25)=-5; % mixed
        part2D(part2Din==32)=-4; % conv elevated
        part2D(part2Din==34)=-3; % conv shallow
        part2D(part2Din==36)=-2; % conv mid
        part2D(part2Din==38)=-1; % conv deep
        
        %% Lightning data
        
        fileL=flistL{minInd};
        
        disp(fileL);
        
        % Read data
        lonL=ncread(fileL,'x0');
        latL=ncread(fileL,'y0');
        
        lightningRate=ncread(fileL,'LtgRate');
        
        % Interpolate lightning data to radar grid
        [lonL2d,latL2d] = meshgrid(lonL,latL);
        lightningInterp=interp2(lonL2d,latL2d,lightningRate',lon2d,lat2d);
        
        lonlatL=[reshape(lon2d,1,[]);reshape(lat2d,1,[]);reshape(lightningInterp,1,[])];
        
        lonlatL(:,any(isnan(lonlatL),1))=[];
        
        %% Lightning per category
        lightningRight=lightningInterp';
        
        countPerCat=zeros(8,1);
        totPix=nan(8,1);
        
        for jj=1:8
            countPerCat(jj)=sum(lightningRight(part2D==jj-9),'omitnan');
            totPix(jj)=sum(sum(part2D==jj-9));
        end
        
        lightSum=sum(sum(lightningRight,'omitnan'));
        
        countPerCatAll=countPerCatAll+countPerCat;
        lightSumAll=lightSumAll+lightSum;
        totPixAll=totPixAll+totPix;
        
        countPerc=countPerCat./lightSum.*100;
        
        %% Has every conv contiguous area lightning?
        
        numAreas=zeros(4,1);
        areasCount={};
        
        for jj=1:4
            convMask=zeros(size(part2D));
            convMask(part2D==jj-5)=1;
            numAreas=bwconncomp(convMask);
            
            % Make list with
            areasCountCat=[];
            for kk=1:numAreas.NumObjects
                pixels=length(numAreas.PixelIdxList{kk});
                flashCount=sum(lightningRight(numAreas.PixelIdxList{kk}),'omitnan');
                areasCountCat=cat(1,areasCountCat,[pixels,flashCount]);
            end
            areasCount{end+1}=areasCountCat;
        end
        
        if ii==1
            areasCountAll=areasCount;
        else
            for jj=1:4
                areasCountAll{jj}=cat(1,areasCountAll{jj},areasCount{jj});
            end
        end
        
        % Calculate statistics
        featTotWithL=nan(4,2);
        lightPerFeatPerPix=nan(4,2);
        numFeat=zeros(4,1);
        
        for jj=1:4
            thisCat=areasCount{1,jj};
            if ~isempty(thisCat)
                featTotWithL(jj,1)=size(thisCat,1);
                featTotWithL(jj,2)=sum(thisCat(:,2)>0);
                lightPerFeatPerPix(jj,1)=mean(thisCat(:,2));
                lightPerFeatPerPix(jj,2)=mean(thisCat(:,2)./thisCat(:,1));
                numFeat(jj)=size(thisCat,1);
            end
        end
        
        numFeatAll=numFeatAll+numFeat;
        percConvWithL=featTotWithL(:,2)./featTotWithL(:,1).*100;
        
        %% Plot Reflectivity and strat/conv/lightning
        
        if plotIndiv
            
            categories={'Strat low','Strat mid','Strat high','Mixed',...
                'Conv elev','Conv shallow','Conv mid','Conv deep'};
            
            close all
            
            figure('Position',[100 100 1700 800],'DefaultAxesFontSize',12)
            colormap('jet')
            
            ax1=subplot('Position',[0.05 0.12 0.43 0.81]);
            colmapL=gray(20);
            colmapPart=[0,0.1,0.6;
                0.38,0.42,0.96;
                0.65,0.74,0.86;
                0.32,0.78,0.59;
                1,0,1;
                1,1,0;
                0.99,0.77,0.22;
                1 0 0];
            colmap=[colmapPart;colmapL];
            
            hold on
            surf(lon,lat,part2D','edgecolor','none');
            view(2)
            xlim([lon(1),lon(end)]);
            ylim([lat(1),lat(end)]);
            caxis([-8 20]);
            colormap(ax1,colmap);
            cb=colorbar;
            cb.Ticks=[-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5,...
                1,5,10,15,20];
            cb.TickLabels=cat(2,categories,{'1','5','10','15','20'});
            
            title('Conv/strat partitioning and lightning density');
            grid on
            xlabel('Longitude (deg)');
            ylabel('Latitude (deg)');
            
            scatter(lonlatL(1,:),lonlatL(2,:),0.1,lonlatL(3,:),'o','filled');
            ax1.SortMethod = 'childorder';
            
            ax2=subplot('Position',[0.58 0.62 0.16 0.31]);
            b=bar(totPix./sum(totPix,'omitnan').*100,1,'FaceColor','flat');
            set(gca,'XTickLabel',categories);
            set(gca,'YTick',0:10:100);
            for kk = 1:8
                b.CData(kk,:) = colmapPart(kk,:);
            end
            xtickangle(45);
            xlim([0.5,8.5]);
            ylim([0,100]);
            set(gca, 'YGrid', 'on');
            
            ylabel('Percent of area [%]')
            title('Area per category');
            
            ax3=subplot('Position',[0.8 0.62 0.16 0.31]);
            b=bar(countPerc,1,'FaceColor','flat');
            set(gca,'XTickLabel',categories);
            set(gca,'YTick',0:10:100);
            for kk = 1:8
                b.CData(kk,:) = colmapPart(kk,:);
            end
            xtickangle(45);
            xlim([0.5,8.5]);
            ylim([0,100]);
            set(gca, 'YGrid', 'on');
            
            ylabel('Percent of strikes [%]')
            title('Lightning distr. per category');
            
            ax4=subplot('Position',[0.58 0.31 0.16 0.15]);
            b=bar(numFeat,1,'FaceColor','flat');
            set(gca,'XTickLabel','');
            for kk = 1:4
                b.CData(kk,:) = colmapPart(kk+4,:);
            end
            xtickangle(45);
            xlim([0.5,4.5]);
            set(gca, 'YGrid', 'on');
            
            ylabel('Count')
            title('Number of features');
            
            ax5=subplot('Position',[0.58 0.12 0.16 0.15]);
            b=bar(percConvWithL,1,'FaceColor','flat');
            set(gca,'XTickLabel',categories(5:8));
            set(gca,'YTick',0:20:100);
            for kk = 1:4
                b.CData(kk,:) = colmapPart(kk+4,:);
            end
            xtickangle(45);
            xlim([0.5,4.5]);
            ylim([0,100]);
            set(gca, 'YGrid', 'on');
            
            ylabel('Percent of features [%]')
            title('Features with lightning');
            
            ax6=subplot('Position',[0.8 0.31 0.16 0.15]);
            b=bar(lightPerFeatPerPix(:,1),1,'FaceColor','flat');
            set(gca,'XTickLabel','');
            for kk = 1:4
                b.CData(kk,:) = colmapPart(kk+4,:);
            end
            xtickangle(45);
            xlim([0.5,4.5]);
            %ylim([0,100]);
            set(gca, 'YGrid', 'on');
            
            ylabel('Count/feature')
            title('Avg. strikes per feature');
            
            ax7=subplot('Position',[0.8 0.12 0.16 0.15]);
            b=bar(lightPerFeatPerPix(:,2),1,'FaceColor','flat');
            set(gca,'XTickLabel',categories(4:8));
            for kk = 1:4
                b.CData(kk,:) = colmapPart(kk+4,:);
            end
            xtickangle(45);
            xlim([0.5,4.5]);
            %ylim([0,100]);
            set(gca, 'YGrid', 'on');
            
            ylabel('Count/pixel')
            title('Avg. strikes per pixel');
            
            mtit(datestr(fileTime,'yyyy-mm-dd HH:MM:SS'),'fontsize',16,'xoff',0.0,'yoff',0.04,'interpreter','none');
            
            print([figdir,'convStrat_lightning_',datestr(fileTime,'yyyymmdd_HHMMSS'),'.png'],'-dpng','-r0')
        end
    end
end

%% Total statistics

% Pixel size in km2
latKM=lldistkm([lat(1),lon(1)],[lat(2),lon(1)]);
lonKM=lldistkm([lat(1),lon(1)],[lat(1),lon(2)]);

pixKM2=latKM*lonKM;

% Calculate statistics
countPercAll=countPerCatAll./lightSumAll.*100;

featTotWithLA=nan(4,2);
lightPerFeat=nan(4,1);

for jj=1:4
    thisCat=areasCountAll{1,jj};
    featTotWithLA(jj,1)=size(thisCat,1);
    featTotWithLA(jj,2)=sum(thisCat(:,2)>0);
    lightPerFeat(jj)=mean(thisCat(:,2));
end

percConvWithLA=featTotWithLA(:,2)./featTotWithLA(:,1).*100;

lightPerArea=countPerCatAll./(totPixAll*pixKM2);

areaCatPerc=totPixAll./sum(totPixAll,'omitnan').*100;
%% Plot
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

close all

figure('Position',[100 100 900 800],'DefaultAxesFontSize',12)
colormap('jet')

ax1=subplot('Position',[0.08 0.62 0.39 0.31]);
b=bar(areaCatPerc,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
set(gca,'YTick',0:10:100);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,100]);
set(gca, 'YGrid', 'on');

ylabel('Percent of area [%]')
title('Area per category');

ax2=subplot('Position',[0.58 0.62 0.38 0.31]);
b=bar(countPercAll,1,'FaceColor','flat');
set(gca,'XTickLabel',categories);
set(gca,'YTick',0:10:100);
for kk = 1:8
    b.CData(kk,:) = colmapPart(kk,:);
end
xtickangle(45);
xlim([0.5,8.5]);
ylim([0,100]);
set(gca, 'YGrid', 'on');

ylabel('Percent of strikes [%]')
title('Lightning distribution per category');

ax3=subplot('Position',[0.08 0.31 0.38 0.15]);
b=bar(numFeatAll,1,'FaceColor','flat');
set(gca,'XTickLabel','');
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
xtickangle(45);
xlim([0.5,4.5]);
set(gca, 'YGrid', 'on');

ylabel('Count')
title('Number of features');

ax4=subplot('Position',[0.08 0.12 0.39 0.15]);
b=bar(percConvWithLA,1,'FaceColor','flat');
set(gca,'XTickLabel',categories(5:8));
set(gca,'YTick',0:20:100);
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
xtickangle(45);
xlim([0.5,4.5]);
ylim([0,100]);
set(gca, 'YGrid', 'on');

ylabel('Percent of features [%]')
title('Features with lightning');

ax5=subplot('Position',[0.58 0.31 0.38 0.15]);
b=bar(lightPerFeat,1,'FaceColor','flat');
set(gca,'XTickLabel','');
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
xtickangle(45);
xlim([0.5,4.5]);
%ylim([0,100]);
set(gca, 'YGrid', 'on');

ylabel('Count/feature')
title('Avg. flashes per feature');

ax6=subplot('Position',[0.58 0.12 0.38 0.15]);
b=bar(lightPerArea(5:8),1,'FaceColor','flat');
set(gca,'XTickLabel',categories(5:8));
for kk = 1:4
    b.CData(kk,:) = colmapPart(kk+4,:);
end
xtickangle(45);
xlim([0.5,4.5]);
%ylim([0,100]);
set(gca, 'YGrid', 'on');

ylabel('Count/km^{2}')
title('Avg. flashes per area');

mtit([datestr(startTime,'yyyy-mm-dd HH:MM'),' to ',datestr(endTime,'yyyy-mm-dd HH:MM')],'fontsize',16,'xoff',0.0,'yoff',0.04,'interpreter','none');

print([figdir,'convStrat_lightning_stats_',...
    datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.png'],'-dpng','-r0')

%% Save data
if saveData
save([figdir,'data_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
    'areaCatPerc','countPercAll','numFeatAll','percConvWithLA','lightPerFeat','lightPerArea');
end
