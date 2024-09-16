
% ECCO-V for NASA APR3 radar data.
% Author: Ulrike Romatschke, NCAR-EOL
% See https://doi.org/10.1175/JTECH-D-22-0019.1 for algorithm description

clear all; % Clear workspace
close all; % Close all figures

% Add path to functions
addpath(genpath('../ecco-v_functions/'));

%% Input variables

% Estimates of the melting layer and divergence level. These are used to
% make the subclassification into shallow, mid, deep, etc.
meltAlt=4.7; % Estimated altitude of melting layer in km
divAlt=8; % Estimated altitude of divergence level in km

% Directory path to APR 3 data. The data needs to be organized into
% subdirectories by date in the format yyyymmdd (20220906). The dataDir
% below needs to point to the parent directory of those subdirectories.
dataDir='/scr/virga1/rsfdata/projects/nasa-apr3/data/3D/';

% Directory for output figures
figdir='/scr/virga1/rsfdata/projects/nasa-apr3/ecco-v-Figs/';

% Set showPlot below to either 'on' or 'off'. If 'on', the figures will pop up on
% the screen and also be saved. If 'off', they will be only saved but will
% not show on the screen while the code runs.
showPlot='off';

% casefile is a text file with start and end times of the data to process.
% The format is yyyy mm dd HH MM for the start time followed by yyyy mm dd
% HH MM of the end time. At the very end there needs to be a 0 for netcdf files
% or a 1 for hdf5 files (E.g. 2022 09 06 16 21 2022 09 06 16 29 0)
% Each case needs to be in a separate line. The file needs to end with a newline for
% matlab to read it properly. Use space as a separator.
casefile='eccoCases_apr3.txt';

%% Tuning parameters

% These tuning parameters affect the boundaries between the
% convective/mixed/stratiform classifications
pixRadDBZ=5; % Horizontal number of pixels over which reflectivity texture is calculated.
% Lower values tend to lead to more stratiform precipitation.
upperLimDBZ=30; % This affects how reflectivity texture translates into convectivity.
% Higher values lead to more stratiform precipitation.
stratMixed=0.4; % Convectivity boundary between strat and mixed.
mixedConv=0.5; % Convectivity boundary between mixed and conv.

dbzBase=0; % Reflectivity base value which is subtracted from DBZ.
% Suggested values are: 0 dBZ for S, C, X, and Ku-band;
% -10 dBZ for Ka-band; -20 dBZ for W-band

% These tuning parameter enlarge mixed and convective regions, join them
% together and fill small holes
enlargeMixed=4; % Enlarges and joins mixed regions
enlargeConv=3; % Enlarges aned joins convective regions

% Echo below the altitude below is removed before processing starts
% to limit the effect of ocean clutter
surfAltLim=1000; % ASL in m

% Remove "speckles". Removes contiguous radar echoes with less than speckNum
% pixels. (To remove noise in clear air.)
speckNum=10;

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

    if caseList.Var11(aa)==0 % NetCDF
        fileList=makeFileList_apr3(dataDir,startTime,endTime,'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx20YYMMDDxhhmmss',1);

        data=[];
        data.lores_zhh14=[];
        data.lores_vel14c=[];
        data.lores_Topo_Hm=[];

        % Load data
        data=read_apr3_3D_nc(fileList,data,startTime,endTime);
    elseif caseList.Var11(aa)==1 % HDF5
        fileList=makeFileList_apr3(dataDir,startTime,endTime,'xxxxxxxxxxxxxx20YYMMDDxhhmmss',1);

        data=[];
        data.zhh14=[];
        data.vel14c=[];
        
        % Load data
        data=read_apr3_3D_h5(fileList,data,startTime,endTime);
        data.TOPO=0;
    else
        error('Wrong data format.')
    end

    %% Prepare data

    % Remove surface echo below a certain altitude
    data.DBZ(data.asl<surfAltLim)=nan;

    % Remove speckles
    maskSub=~isnan(data.DBZ);
    maskSub=bwareaopen(maskSub,speckNum);

    data.DBZ(maskSub==0)=nan;

    % Create a fake melting layer based on meltAlt
    data.MELTING_LAYER=nan(size(data.DBZ));
    data.MELTING_LAYER(data.asl>=meltAlt.*1000)=20;
    data.MELTING_LAYER(data.asl<meltAlt.*1000)=10;

    % Create a fake temperature profile based on divAlt
    data.TEMP=nan(size(data.DBZ));
    data.TEMP(data.asl>=divAlt.*1000)=-30;
    data.TEMP(data.asl<divAlt.*1000)=10;

    %% Texture from reflectivity

    disp('Calculating reflectivity texture ...');

    dbzText=f_reflTexture(data.DBZ,pixRadDBZ,dbzBase);

    %% Convectivity

    convDBZ=1/upperLimDBZ.*dbzText;

    %% Basic classification

    disp('Basic classification ...');

    classBasic=f_classBasic(convDBZ,stratMixed,mixedConv,data.MELTING_LAYER,enlargeMixed,enlargeConv);

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

    % Set up the 1D classification at the bottom of the plot
    stratConv1D=max(classSubPlot,[],1);
    time1D=data.time(~isnan(stratConv1D));
    stratConv1D=stratConv1D(~isnan(stratConv1D));

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

    col1D=colmapSC(stratConv1D,:);

    % Determine upper limit of y axis based on where the valid data ends
    ylimUpper=(max(data.asl(~isnan(data.DBZ)))./1000)+0.5;
    % Altitude of the labels within the subplots
    textAlt=ylimUpper-1;
    % Time of the labels within the subplots
    textDate=data.time(1)+seconds(5);

    close all

    f1 = figure('Position',[200 500 1600 1100],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    % Plot reflectivity
    s1=subplot(4,1,1);

    hold on
    surf(data.time,data.asl./1000,data.DBZ,'edgecolor','none');
    view(2);
    ylabel('Altitude (km)');
    clim([-10 60]);
    ylim([0 ylimUpper]);
    xlim([data.time(1),data.time(end)]);
    set(gca,'XTickLabel',[]);
    cb1=colorbar;
    grid on
    box on

    text(textDate,textAlt,'(a) Reflectivity (dBZ)','FontSize',11,'FontWeight','bold');

    % Plot convectivity
    s2=subplot(4,1,2);

    hold on
    surf(data.time,data.asl./1000,convDBZ,'edgecolor','none');
    view(2);
    ylabel('Altitude (km)');
    clim([0 1]);
    ylim([0 ylimUpper]);
    xlim([data.time(1),data.time(end)]);
    cb2=colorbar;
    set(gca,'XTickLabel',[]);
    grid on
    box on
    text(textDate,textAlt,'(b) Convectivity','FontSize',11,'FontWeight','bold');

    % Plot the 1D classification at the very bottom (needs to be done
    % before the last plot for matlab specific reasons)
    s5=subplot(30,1,30);

    hold on
    scat1=scatter(time1D,ones(size(time1D)),10,col1D,'filled');
    set(gca,'clim',[0,1]);
    set(gca,'YTickLabel',[]);
    s5.Colormap=colmapSC;
    xlim([data.time(1),data.time(end)]);
    grid on
    box on

    % Plot classification
    s4=subplot(4,1,3);

    hold on
    surf(data.time,data.asl./1000,classSubPlot,'edgecolor','none');
    view(2);
    ylabel('Altitude (km)');
    clim([0 10]);
    ylim([0 ylimUpper]);
    xlim([data.time(1),data.time(end)]);
    s4.Colormap=colmapSC;
    clim([0.5 9.5]);
    cb4=colorbar;
    cb4.Ticks=1:9;
    cb4.TickLabels={'Strat Low','Strat Mid','Strat High','Mixed',...
        'Conv','Conv Elev','Conv Shallow','Conv Mid','Conv Deep'};
    set(gca,'XTickLabel',[]);
    grid on
    box on
    text(textDate,textAlt,'(c) Echo type','FontSize',11,'FontWeight','bold');

    % Matlab by default creates a lot of white space so we reposition the
    % panels to avoid that
    s1.Position=[0.049 0.69 0.82 0.29];
    s2.Position=[0.049 0.38 0.82 0.29];
    s4.Position=[0.049 0.07 0.82 0.29];
    s5.Position=[0.049 0.035 0.82 0.02];

    % The color bars also need to be repositioned
    cb1.Position=[0.875,0.69,0.02,0.29];
    cb2.Position=[0.875,0.38,0.02,0.29];
    cb4.Position=[0.875,0.07,0.02,0.29];

    % Save the figure based on the start and end time
    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,'apr3_',datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS'),'.png'],'-dpng','-r0')
end