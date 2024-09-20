% ECCO-V for S-Pol RHI radar data.
% Author: Ulrike Romatschke, NCAR-EOL
% See https://doi.org/10.1175/JTECH-D-22-0019.1 for algorithm description

clear all; % Clear workspace
close all; % Close all figures

% Add path to functions
addpath(genpath('../ecco-v_functions/'));

%% Input variables

% Directory path to RHI data. The data needs to be organized into
% subdirectories by date in the format yyyymmdd (20220906). The dataDir
% below needs to point to the parent directory of those subdirectories.
dataDir='/scr/cirrus3/rsfdata/projects/precip/grids/spol/radarPolar/qc2/rate/sband/v2.0/rhi/';

% Directory for output figures
figdir='/scr/cirrus3/rsfdata/projects/precip/grids/spol/radarPolar/qc2/rate/plots/ecco_v-RHIs/';

% Directory for output mat files
saveFiles=1; % If output mat files should be saved, set to 1. If not, set to 0.
outdir='/scr/cirrus3/rsfdata/projects/precip/grids/spol/radarPolar/qc2/rate/plots/ecco_v-RHIs/matFiles/';

% Set showPlot below to either 'on' or 'off'. If 'on', the figures will pop up on
% the screen and also be saved. If 'off', they will be only saved but will
% not show on the screen while the code runs.
showPlot='on';

startTime=datetime(2022,6,8,0,0,0);
endTime=datetime(2022,6,8,0,30,0);

%% Tuning parameters

% These tuning parameters affect the boundaries between the
% convective/mixed/stratiform classifications
pixRadDBZ=132; % Horizontal number of pixels over which reflectivity texture is calculated.
% 3 km: 79; 5 km: 132; 7 km 185
% Lower values tend to lead to more stratiform precipitation.
upperLimDBZ=35; % This affects how reflectivity texture translates into convectivity.
% Higher values lead to more stratiform precipitation.
stratMixed=0.4; % Convectivity boundary between strat and mixed.
mixedConv=0.5; % Convectivity boundary between mixed and conv.

dbzBase=0; % Reflectivity base value which is subtracted from DBZ.
% Suggested values are: 0 dBZ for S, C, X, and Ku-band;
% -10 dBZ for Ka-band; -20 dBZ for W-band

% These tuning parameter enlarge mixed and convective regions, join them
% togethre and fill small holes
enlargeMixed=5; % Enlarges and joins mixed regions
enlargeConv=5; % Enlarges aned joins convective regions

% Echo below this altitude is removed before processing
% to limit the effect of ocean clutter
surfAltLim=1000; % ASL in m

%% Loop through the files
fileList=makeFileList_spol(dataDir,startTime,endTime,'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx20YYMMDDxhhmmss',1);

for aa=1:length(fileList)

    disp(['File ',num2str(aa),' of ',num2str(length(fileList))]);

    %% Read data

    disp("Getting data ...");

    % Create a file list with files between the start and end time of the
    % case. Then load the data

    dataFile=[];
    dataFile.DBZ_F=[];
    dataFile.TEMP_FOR_PID=[];
    
    % Load data
    dataFile=read_spol(fileList{aa},dataFile);

    %% Loop through RHIs
    for ii=1:size(dataFile,2)
        
        dataPol=dataFile(ii);

        if dataPol.time(1)<startTime
            continue
        end

        %% Interpolate data

        disp(['RHI ',num2str(ii),' of ',num2str(size(dataFile,2))]);
        disp('Interpolating to Cartesian grid ...');

        elevPad=cat(1,nan,dataPol.elevation,nan);
        elevPad=fillmissing(elevPad,'linear');

        rangePad=cat(2,nan,dataPol.range,nan);
        rangePad=fillmissing(rangePad,'linear');

        [phi,r]=meshgrid(deg2rad(elevPad),rangePad);
        [Xin,Yin]=pol2cart(phi,r);

        [X,Y]=meshgrid(dataPol.range(1):(dataPol.range(2)-dataPol.range(1))/4:dataPol.range(end),surfAltLim/1000:0.1:25);

        % Reflectivity
        dbzIn=dataPol.DBZ_F';
        dbzIn=padarray(dbzIn,[1,1],nan,'both');
        intDBZ=scatteredInterpolant(double(Xin(:)),double(Yin(:)),dbzIn(:),'nearest');
        data.DBZ=intDBZ(double(X),double(Y));

        % Temperature
        tempIn=dataPol.TEMP_FOR_PID';
        tempIn=padarray(tempIn,[1,1],nan,'both');
        intTEMP=scatteredInterpolant(double(Xin(:)),double(Yin(:)),tempIn(:),'nearest');
        data.TEMP=intTEMP(double(X),double(Y));
        
        %% Prepare data
               
        % % Remove specles
        % maskSub=~isnan(data.DBZ);
        % maskSub=bwareaopen(maskSub,10);
        % 
        % data.DBZ(maskSub==0)=nan;

        % Create a fake melting layer based on meltAlt
        data.MELTING_LAYER=nan(size(data.DBZ));
        data.MELTING_LAYER(data.TEMP<=0)=20;
        data.MELTING_LAYER(data.TEMP>0)=10;

        data.TOPO=0;

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

        classSub=f_classSub(classBasic,Y.*1000,data.TOPO,data.MELTING_LAYER,data.TEMP,[],[],surfAltLim);

        %% Save output data
        if saveFiles
            disp('Saving data ...');

            ecco.X=X;
            ecco.Y=Y;
            ecco.DBZ=data.DBZ;
            ecco.CONVECTIVITY=convDBZ;
            ecco.ECHO_TYPE=classSub;

            save([outdir,'spol_',datestr(dataPol.time(1),'yyyymmdd_HHMMSS'),'.mat'],'ecco');
        end

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

        % Determine upper limit of y axis based on where the valid data ends
        ylimUpper=25;
               
        close all

        f1 = figure('Position',[200 500 1200 1200],'DefaultAxesFontSize',12,'visible',showPlot);
        colormap('jet');
        t = tiledlayout(4,1,'TileSpacing','tight','Padding','tight');
        
        % Plot polar reflectivity
        s1=nexttile(1);
        
        hold on
        surf(Xin(2:end-1,2:end-1),Yin(2:end-1,2:end-1),dataPol.DBZ_F','edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([-10 50]);
        xlim([0,max(dataPol.range)]);
        ylim([0,25]);

        xlabel('Range (km)');
        ylabel('Altitude (km)');

        cb1=colorbar;
        grid on
        box on

        title('Polar reflectivity (dBZ)');

        % Plot Cartesian reflectivity
        s2=nexttile(2);
        
        hold on
        surf(X,Y,data.DBZ,'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([-10 50]);
        xlim([0,max(dataPol.range)]);
        ylim([0,25]);

        xlabel('Range (km)');
        ylabel('Altitude (km)');

        cb2=colorbar;
        grid on
        box on

        title('Cartesian reflectivity (dBZ)');

        % Plot convectivity
        s3=nexttile(3);
        
        hold on
        surf(X,Y,convDBZ,'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([0 1]);
        xlim([0,max(dataPol.range)]);
        ylim([0,25]);

        xlabel('Range (km)');
        ylabel('Altitude (km)');

        cb3=colorbar;
        grid on
        box on

        title('Convectivity');

        % Plot classification
        s4=nexttile(4);
        
        hold on
        surf(X,Y,classSubPlot,'edgecolor','none');
        view(2);
        ylabel('Altitude (km)');
        clim([-10 60]);
        xlim([0,max(dataPol.range)]);
        ylim([0,25]);

        xlabel('Range (km)');
        ylabel('Altitude (km)');

        s4.Colormap=colmapSC;
        clim([0.5 9.5]);
        cb4=colorbar;
        cb4.Ticks=1:9;
        cb4.TickLabels={'Strat Low','Strat Mid','Strat High','Mixed',...
            'Conv','Conv Elev','Conv Shallow','Conv Mid','Conv Deep'};
                
        grid on
        box on

        title('Echo type');

        % Save the figure based on the start and end time
        set(gcf,'PaperPositionMode','auto')
        print(f1,[figdir,'spol_',datestr(dataPol.time(1),'yyyymmdd_HHMMSS'),'.png'],'-dpng','-r0')
    end
end