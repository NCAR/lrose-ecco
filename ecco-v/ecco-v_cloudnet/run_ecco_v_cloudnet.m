
% ECCO-V for Cloudnet radar data.
% Author: Ulrike Romatschke, NCAR-EOL
% See https://doi.org/10.1175/JTECH-D-22-0019.1 for algorithm description

clear all; % Clear workspace
close all; % Close all figures

% Add path to functions
addpath(genpath('../ecco-v_functions/'));

%% Input variables

instance='leipzig'; % leipzig or puntaArenas

% Save output data
saveData=1;
outdir=['/scr/virga1/rsfdata/projects/cloudnet/matFiles/',instance,'/'];

% Directory path to Cloudnet data. The data needs to be organized into
% subdirectories by date in the format yyyymmdd (20220906). The dataDir
% below needs to point to the parent directory of those subdirectories.
dataDir=['/scr/virga1/rsfdata/projects/cloudnet/',instance,'/'];

% Directory for output figures
figdir=['/scr/virga1/rsfdata/projects/cloudnet/ecco-v-Figs/',instance,'/'];

% Set showPlot below to either 'on' or 'off'. If 'on', the figures will pop up on
% the screen and also be saved. If 'off', they will be only saved but will
% not show on the screen while the code runs.
showPlot='off';

% casefile is a text file with start and end times of the data to process.
% The format is yyyy mm dd HH MM for the start time followed by yyyy mm dd
% HH MM of the end time. (E.g. 2022 09 06 16 21 2022 09 06 16 29)
% Each case needs to be in a separate line. The file needs to end with a newline for
% matlab to read it properly. Use space as a separator.
casefile=['eccoCases_cloudnet_',instance,'.txt'];

%% Tuning parameters

% These tuning parameters affect the boundaries between the
% convective/mixed/stratiform classifications
pixRad=19; % Horizontal number of pixels over which textures are calculated.
% Lower values tend to lead to more stratiform precipitation.

upperLimDBZ=12; % This affects how reflectivity texture translates into convectivity.
% Higher values lead to more stratiform precipitation.
upperLimVEL=5; % This affects how velocity texture translates into convectivity.
% Higher values lead to more stratiform precipitation.

stratMixed=0.4; % Convectivity boundary between strat and mixed.
mixedConv=0.5; % Convectivity boundary between mixed and conv.

dbzBase=-10; % Reflectivity base value which is subtracted from DBZ.
% Suggested values are: 0 dBZ for S, C, X, and Ku-band;
% -10 dBZ for Ka-band and W-band
velBase=-20; % Velocity base value which is subtracted from VEL.
% Suggested value is -20 m/s which will handle most up/down drafts.

% These tuning parameter enlarge mixed and convective regions, join them
% together and fill small holes
enlargeMixed=1; % Enlarges and joins mixed regions
enlargeConv=1; % Enlarges aned joins convective regions

% Echo below the altitude below is removed before processing starts
% to limit the effect of ocean clutter
surfAltLim=0; % ASL in m

% Remove "speckles". Removes contiguous radar echoes with less than speckNum
% pixels. (To remove noise in clear air.)
speckNum=0;

firstGate=1; % First range gate with good data

%% Loop through the cases

caseList=readtable(casefile);
caseStart=datetime(caseList.Var1,caseList.Var2,caseList.Var3, ...
    caseList.Var4,caseList.Var5,0);
caseEnd=datetime(caseList.Var6,caseList.Var7,caseList.Var8, ...
    caseList.Var9,caseList.Var10,0);

for aa=1:length(caseStart)

    disp(['Case ',num2str(aa),' of ',num2str(length(caseStart))]);

    startTime=caseStart(aa);
    endTime=caseEnd(aa);

    %% Read data

    disp("Getting data ...");

    % Create a file list with files between the start and end time of the
    % case. Then load the data


    fileList=makeFileList_cloudnet(dataDir,startTime,endTime,'20YYMMDD');

    data=[];
    data.Z=[];
    data.v=[];
    data.category_bits=[];
       
    % Load data
    data=read_cloudnet(fileList,data,startTime,endTime);

    data.elevation=repmat(90,1,length(data.time));

    data.DBZ=data.Z;
    data=rmfield(data,'Z');

    data.VEL=data.v;
    data=rmfield(data,'v');
        
    %% Prepare data

    % Remove surface echo below a certain altitude
    data.DBZ(data.asl<surfAltLim)=nan;

    % Remove speckles
    maskSub=~isnan(data.DBZ);
    maskSub=bwareaopen(maskSub,speckNum);

    data.DBZ(maskSub==0)=nan;

    % Convert categories to melting layer
    % De-code bits
    cBits=nan(size(data.DBZ,1),size(data.DBZ,2),6);
    for ii=1:size(data.DBZ,1)
        for jj=1:size(data.DBZ,2)
            cBits(ii,jj,:)=bitget(data.category_bits(ii,jj),1:6,'int32');
        end
    end

    data.MELTING_LAYER=nan(size(data.DBZ));
    data.MELTING_LAYER(cBits(:,:,3)==0)=10;
    data.MELTING_LAYER(cBits(:,:,3)==1)=20;

    %% Texture from reflectivity

    disp('Calculating reflectivity texture ...');

    dbzText=f_reflTexture(data.DBZ,pixRad,dbzBase);

    %% Texture from velocity

    disp('Calculating velocity texture ...');

    velText=f_velTexture(data.VEL,pixRad,velBase);

    %% Convectivity

    convDBZ=1/upperLimDBZ.*dbzText;

    convVEL=1/upperLimVEL.*velText;

    convectivity=convDBZ.*convVEL;
    convectivity(convectivity>1)=1;
    convectivity(isnan(convectivity))=convDBZ(isnan(convectivity));

    %% Basic classification

    disp('Basic classification ...');

    classBasic=f_classBasic(flipud(convectivity),flipud(stratMixed),flipud(mixedConv),flipud(data.MELTING_LAYER),enlargeMixed,enlargeConv);

    classBasic=flipud(classBasic);
    
    %% Sub classification

    disp('Sub classification ...');

    classSub=f_classSub(classBasic,data.asl,data.TOPO,data.MELTING_LAYER,data.TEMP,data.elevation,firstGate,surfAltLim);

    %% Plot

    disp('Plotting ...');

    % Change the default values of the subclassification to something that
    % is easier to plot
    classSubPlot=classSub;
    classSubPlot(classSub==14)=1;
    classSubPlot(classSub==16)=2;
    classSubPlot(classSub==18)=3;
    classSubPlot(classSub==25)=4;
    classSubPlot(classSub==30)=5;
    classSubPlot(classSub==32)=6;
    classSubPlot(classSub==34)=7;
    classSubPlot(classSub==36)=8;
    classSubPlot(classSub==38)=9;

    % Set up color maps
    colmapSC=[0,0.1,0.6;
        0.38,0.42,0.96;
        0.65,0.74,0.86;
        0.32,0.78,0.59;
        1,0,0;
        1,0,1;
        1,1,0;
        0.99,0.77,0.22;
        0.7,0,0];

    threeDays=startTime:hours(72):endTime;
    threeDays=cat(2,threeDays,endTime);

    for kk=1:length(threeDays)-1

        timeInds=find(data.time>=threeDays(kk) & data.time<threeDays(kk+1));
        if isempty(timeInds)
            continue
        end

        % Set up the 1D classification at the bottom of the plot
        stratConv1D=max(classSubPlot(:,timeInds),[],1);
        timeThis=data.time(:,timeInds);
        time1D=timeThis(~isnan(stratConv1D));
        stratConv1D=stratConv1D(~isnan(stratConv1D));

        col1D=colmapSC(stratConv1D,:);

        % Determine upper limit of y axis based on where the valid data ends
        %ylimUpper=(max(data.asl(~isnan(data.DBZ)))./1000)+0.5;
        ylimUpper=12;
        % Altitude of the labels within the subplots
        textAlt=ylimUpper-1;
       
        close all

        f1 = figure('Position',[200 500 1600 1200],'DefaultAxesFontSize',12,'visible',showPlot);

        colormap('jet');

        % Plot reflectivity
        s1=subplot(5,1,1);

        hold on
        surf(data.time(:,timeInds),data.asl(:,timeInds)./1000,data.DBZ(:,timeInds),'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([-30 25]);
        ylim([0 ylimUpper]);
        xlim([threeDays(kk),threeDays(kk+1)]);
        set(gca,'XTickLabel',[]);
        cb1=colorbar;
        grid on
        box on

        title('(a) Reflectivity (dBZ)','FontSize',11,'FontWeight','bold');

        % Plot velocity
        s2=subplot(5,1,2);

        hold on
        surf(data.time(:,timeInds),data.asl(:,timeInds)./1000,data.VEL(:,timeInds),'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([-12 12]);
        ylim([0 ylimUpper]);
        xlim([threeDays(kk),threeDays(kk+1)]);
        set(gca,'XTickLabel',[]);
        s2.Colormap=flipud(velCols);
        cb2=colorbar;
        grid on
        box on

        title('(b) Velocity (m s^{-1})','FontSize',11,'FontWeight','bold');

        % Plot convectivity
        s3=subplot(5,1,3);

        hold on
        surf(data.time(:,timeInds),data.asl(:,timeInds)./1000,convectivity(:,timeInds),'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([0 1]);
        ylim([0 ylimUpper]);
        xlim([threeDays(kk),threeDays(kk+1)]);
        cb2=colorbar;
        set(gca,'XTickLabel',[]);
        grid on
        box on
        title('(c) Convectivity','FontSize',11,'FontWeight','bold');

        % Plot the 1D classification at the very bottom (needs to be done
        % before the last plot for matlab specific reasons)
        s5=subplot(30,1,30);

        hold on
        scat1=scatter(time1D,ones(size(time1D)),10,col1D,'filled');
        set(gca,'clim',[0,1]);
        set(gca,'YTickLabel',[]);
        s5.Colormap=colmapSC;
        xlim([threeDays(kk),threeDays(kk+1)]);
        grid on
        box on

        % Plot classification
        s4=subplot(5,1,4);

        hold on
        surf(data.time(:,timeInds),data.asl(:,timeInds)./1000,classSubPlot(:,timeInds),'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([0 10]);
        ylim([0 ylimUpper]);
        xlim([threeDays(kk),threeDays(kk+1)]);
        s4.Colormap=colmapSC;
        clim([0.5 9.5]);
        cb4=colorbar;
        cb4.Ticks=1:9;
        cb4.TickLabels={'Strat Low','Strat Mid','Strat High','Mixed',...
            'Conv','Conv Elev','Conv Shallow','Conv Mid','Conv Deep'};
        set(gca,'XTickLabel',[]);
        grid on
        box on
        title('(d) Echo type','FontSize',11,'FontWeight','bold');

        % Matlab by default creates a lot of white space so we reposition the
        % panels to avoid that
        xp=0.041;
        ht=0.21;
        wi=0.87;
        s1.Position=[xp 0.77 wi ht];
        s2.Position=[xp 0.535 wi ht];
        s3.Position=[xp 0.3 wi ht];
        s4.Position=[xp 0.065 wi ht];
        s5.Position=[xp 0.03 wi 0.02];

        % Save the figure based on the start and end time
        set(gcf,'PaperPositionMode','auto')
        print(f1,[figdir,'cloudnet_',datestr(threeDays(kk),'yyyymmdd'),'_to_',datestr(threeDays(kk+1),'yyyymmdd'),'.png'],'-dpng','-r0')
    end
    %% Save
    if saveData
        disp('Saving stratConv field ...')

        % convectivity=nan(size(data.DBZ));
        % convectivity(:,nonMissingInds==1)=convectivityShort;

        % convStrat=nan(size(data.DBZ));
        % convStrat(:,nonMissingInds==1)=classSub;
        convStrat=classSub;
        convStrat1D=max(convStrat,[],1);

        save([outdir,instance,'.convectivity.',datestr(startTime,'YYYYmmDD'),'.mat'],'convectivity');

        save([outdir,instance,'.convStrat.',datestr(startTime,'YYYYmmDD'),'.mat'],'convStrat');

        save([outdir,instance,'.convStrat1D.',datestr(startTime,'YYYYmmDD'),'.mat'],'convStrat1D');

        time=data.time;
        save([outdir,instance,'.time.',datestr(startTime,'YYYYmmDD'),'.mat'],'time');
    end
end