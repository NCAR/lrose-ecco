
% ECCO-V for NASA APR3 radar data.
% Author: Ulrike Romatschke, NCAR-EOL
% See https://doi.org/10.1175/JTECH-D-22-0019.1 for algorithm description
% This script saves the 1D classification into text files

clear all; % Clear workspace
close all; % Close all figures

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
figdir='/scr/virga1/rsfdata/projects/nasa-apr3/ecco-v-Figs/class1D/';

% Set showPlot below to either 'on' or 'off'. If 'on', the figures will pop up on
% the screen and also be saved. If 'off', they will be only saved but will
% not show on the screen while the code runs.
showPlot='on';

% casefile is a text file with start and end times of the data to process.
% The format is yyyy mm dd HH MM for the start time followed by yyyy mm dd
% HH MM of the end time. At the very end there needs to be a 0 for netcdf files
% or a 1 for hdf5 files (E.g. 2022 09 06 16 21 2022 09 06 16 29 0)
% Each case needs to be in a separate line. The file needs to end with a newline for
% matlab to read it properly. Use space as a separator.
casefile='eccoCases_apr3_save1D.txt';

%% Tuning parameters

% These two tuning parameters affect the classification
pixRadDBZ=5; % Horizontal number of pixels over which reflectivity texture is calculated.
upperLimDBZ=30; % This affects how reflectivity texture translates into convectivity.

% Echo below the altitude below is removed before processing starts
% to limit the effect of ocean clutter
surfAltLim=1000; % ASL in m

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

    % Remove specles
    maskSub=~isnan(data.DBZ);
    maskSub=bwareaopen(maskSub,10);

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

    dbzBase=0; % Reflectivity base value which is subtracted from DBZ.
    dbzText=f_reflTexture(data.DBZ,pixRadDBZ,dbzBase);

    %% Convectivity

    convDBZ=1/upperLimDBZ.*dbzText;

    %% Basic classification

    disp('Basic classification ...');

    stratMixed=0.4; % Convectivity boundary between strat and mixed.
    mixedConv=0.5; % Convectivity boundary between mixed and conv.

    classBasic=f_classBasic(convDBZ,stratMixed,mixedConv,data.MELTING_LAYER);

    %% Sub classification

    disp('Sub classification ...');

    classSub=f_classSub(classBasic,data.asl,data.TOPO,data.MELTING_LAYER,data.TEMP);

    %% Plot

    disp('Plotting ...');

    % Change the default values of the subclassification to something that
    % is easier to plot
    classSubPlot=classSub;
    classSubPlot(classSub==14)=1;
    classSubPlot(classSub==16)=1;
    classSubPlot(classSub==18)=1;
    classSubPlot(classSub==25)=1;
    classSubPlot(classSub==30)=1;
    classSubPlot(classSub==32)=2;
    classSubPlot(classSub==34)=2;
    classSubPlot(classSub==36)=2;
    classSubPlot(classSub==38)=2;

    % Set up the 1D classification at the bottom of the plot
    stratConv1D=max(classSubPlot,[],1);
    stratConv1D(isnan(stratConv1D))=0;
    
    % Set up color maps
    col1D=[1,1,1;
        0,0,1;
        1,0,0];

    % Determine upper limit of y axis based on where the valid data ends
    ylimUpper=(max(data.asl(~isnan(data.DBZ)))./1000)+0.5;
    % Altitude of the labels within the subplots
    textAlt=ylimUpper-1;
    % Time of the labels within the subplots
    textDate=data.time(1)+minutes(3);

    close all

    f1 = figure('Position',[200 500 2800 600],'DefaultAxesFontSize',12,'visible',showPlot);

    colormap('jet');

    % Plot reflectivity
    s1=subplot(2,1,1);

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

    text(textDate,textAlt,'Reflectivity (dBZ)','FontSize',11,'FontWeight','bold');
    title(['APR3 ',datestr(data.time(1),'yyyy-mm-dd HH:MM:SS'),' to ',datestr(data.time(end),'yyyy-mm-dd HH:MM:SS')]);

    % Plot the 1D classification at the very bottom (needs to be done
    % before the last plot for matlab specific reasons)
    s2=subplot(5,1,5);

    hold on
    scat1=scatter(data.time,stratConv1D,10,'k','filled');
    s2.YTick=0:2;
    s2.YTickLabel={'Missing';'Stratiform';'Convective'};
    ylim([-1,3])
    xlim([data.time(1),data.time(end)]);
    grid on
    box on

    % Matlab by default creates a lot of white space so we reposition the
    % panels to avoid that
    s1.Position=[0.035 0.19 0.93 0.72];
    s2.Position=[0.035 0.08 0.93 0.09];
    
    % The color bars also need to be repositioned
    cb1.Position=[0.97,0.19,0.01,0.72];
      
    % Save the figure based on the start and end time
    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,'apr3_',datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS'),'.png'],'-dpng','-r0')

    %% Save 1D classification and time

    varNames={'Year';'Month';'Day';'Hour';'Minute';'Second';'Classification'};
    Tout=table(year(data.time)',month(data.time)',day(data.time)', ...
        hour(data.time)',minute(data.time)',second(data.time)',stratConv1D');
    Tout.Properties.VariableNames=varNames;

    writetable(Tout,[figdir,'apr3_',datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS'),'.txt']);
end