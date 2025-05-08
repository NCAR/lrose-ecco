% Add ecco output to cfradial files

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input variables %%%%%%%%%%%%%%%%%%%%%%%%%%

instance='leipzig'; % leipzig or puntaArenas

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('../ecco-v_functions/'));

indir=['/scr/virga1/rsfdata/projects/cloudnet/eccoData/',instance,'/'];

matdir=['/scr/virga1/rsfdata/projects/cloudnet/matFiles/',instance,'/'];

casefile=['eccoCases_cloudnet_',instance,'.txt'];

%% Run processing

caseList=readtable(casefile);
caseStart=datetime(caseList.Var1,caseList.Var2,caseList.Var3, ...
    caseList.Var4,caseList.Var5,0);
caseEnd=datetime(caseList.Var6,caseList.Var7,caseList.Var8, ...
    caseList.Var9,caseList.Var10,0);

for ii=1:length(caseStart)

    disp(['Case ',num2str(ii),' of ',num2str(length(caseStart))]);

    startTime=caseStart(ii);
    endTime=caseEnd(ii);

    fileList=makeFileList_cloudnet(indir,startTime,endTime,'20YYMMDD');

    % Get model data
    dateFile=datestr(startTime,'yyyymm');

    load([matdir,instance,'.convectivity.',dateFile,'01.mat']);
    load([matdir,instance,'.convStrat1D.',dateFile,'01.mat']);
    load([matdir,instance,'.convStrat.',dateFile,'01.mat']);
    load([matdir,instance,'.time.',dateFile,'01.mat']);

    timeEccoNum=datenum(time);

    if ~isempty(fileList)

        %% Loop through HCR data files
        for jj=1:length(fileList)
            infile=fileList{jj};
            
            disp(infile);

            testField=[];
            try
                testField=ncread(infile,'CONVECTIVITY');
            end
            if ~isempty(testField)
                warning('Field already exists. Skipping file.')
                continue
            end       

            % Find times that are equal
            fileSpl=strsplit(infile,'/');
            filePart=fileSpl{end};
            startTimeFile=datetime(str2num(filePart(1:4)),str2num(filePart(5:6)),str2num(filePart(7:8)));
            timeRead=ncread(infile,'time')';
            timeCloudnet=startTimeFile+hours(timeRead);

            timeCloudnetNum=datenum(timeCloudnet);
            
            [C,ia,ib] = intersect(timeCloudnetNum,timeEccoNum);
            
            if length(timeCloudnet)~=length(ib)
                warning('Times do not match up. Skipping file.')
                continue
            end
            
            % Write output
            fillVal=-99;                        

            modOut.convectivity=convectivity(:,ib);
            modOut.convectivity(isnan(modOut.convectivity))=fillVal;
            modOut.convStrat=convStrat(:,ib);
            modOut.convStrat(isnan(modOut.convStrat))=fillVal;
            modOut.convStrat1D=convStrat1D(:,ib);
            modOut.convStrat1D(isnan(modOut.convStrat1D))=fillVal;
                              
            % Open file
            ncid = netcdf.open(infile,'WRITE');
            netcdf.setFill(ncid,'FILL');
            
            % Get dimensions
            dimtime = netcdf.inqDimID(ncid,'time');
            dimheight = netcdf.inqDimID(ncid,'height');
            
            % Define variables
            netcdf.reDef(ncid);
            varidConv = netcdf.defVar(ncid,'CONVECTIVITY','NC_FLOAT',[dimheight dimtime]);
            netcdf.defVarFill(ncid,varidConv,false,fillVal);
            varidSC2D = netcdf.defVar(ncid,'ECHO_TYPE_2D','NC_SHORT',[dimheight dimtime]);
            netcdf.defVarFill(ncid,varidSC2D,false,fillVal);
            varidSC1D = netcdf.defVar(ncid,'ECHO_TYPE_1D','NC_SHORT',[dimtime]);
            netcdf.defVarFill(ncid,varidSC1D,false,fillVal);
            netcdf.endDef(ncid);
            
            % Write variables
            netcdf.putVar(ncid,varidConv,modOut.convectivity);
            netcdf.putVar(ncid,varidSC2D,modOut.convStrat);
            netcdf.putVar(ncid,varidSC1D,modOut.convStrat1D);
                       
            netcdf.close(ncid);
            
            % Write attributes
            ncwriteatt(infile,'CONVECTIVITY','long_name','convective_probability');
            ncwriteatt(infile,'CONVECTIVITY','standard_name','convectivity');
            ncwriteatt(infile,'CONVECTIVITY','units','');
            ncwriteatt(infile,'CONVECTIVITY','grid_mapping','grid_mapping');
            ncwriteatt(infile,'CONVECTIVITY','coordinates','time height');
            
            ncwriteatt(infile,'ECHO_TYPE_2D','long_name','echo_type_2D');
            ncwriteatt(infile,'ECHO_TYPE_2D','standard_name','echo_type');
            ncwriteatt(infile,'ECHO_TYPE_2D','units','');
            ncwriteatt(infile,'ECHO_TYPE_2D','flag_values',[14, 16, 18, 25, 30, 32, 34, 36, 38]);
            ncwriteatt(infile,'ECHO_TYPE_2D','flag_meanings',...
                'strat_low strat_mid strat_high mixed conv conv_elevated conv_shallow conv_mid conv_deep');
            ncwriteatt(infile,'ECHO_TYPE_2D','is_discrete','true');
            ncwriteatt(infile,'ECHO_TYPE_2D','grid_mapping','grid_mapping');
            ncwriteatt(infile,'ECHO_TYPE_2D','coordinates','time height');
                        
            ncwriteatt(infile,'ECHO_TYPE_1D','long_name','echo_type_1D');
            ncwriteatt(infile,'ECHO_TYPE_1D','standard_name','echo_type');
            ncwriteatt(infile,'ECHO_TYPE_1D','units','');
            ncwriteatt(infile,'ECHO_TYPE_1D','flag_values',[14, 16, 18, 25, 30, 32, 34, 36, 38]);
            ncwriteatt(infile,'ECHO_TYPE_1D','flag_meanings',...
                'strat_low strat_mid strat_high mixed conv conv_elevated conv_shallow conv_mid conv_deep');
            ncwriteatt(infile,'ECHO_TYPE_1D','is_discrete','true');
            ncwriteatt(infile,'ECHO_TYPE_1D','grid_mapping','grid_mapping');
            ncwriteatt(infile,'ECHO_TYPE_1D','coordinates','time');
        end
    end
end
