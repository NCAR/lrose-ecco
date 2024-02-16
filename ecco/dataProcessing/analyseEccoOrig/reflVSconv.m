% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/gitPriv/utils/'));

startTime=datetime(2015,6,1,0,0,0);
endTime=datetime(2015,7,17,0,0,0);

% startTime=datetime(2015,6,1,0,0,0);
% endTime=datetime(2015,6,1,3,0,0);

reflThresh=50;

saveData=1;

indir=['/scr/rain2/rsfdata/projects/pecan/mdv/conv_strat/new/'];

outdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/highRefl/'];

flist=makeFileList(indir,startTime,endTime,'20YYMMDDxhhmmss',1);

%% Loop through radar files

textureAll=[];
convectivityAll=[];
dbzAll=[];
part3dAll=[];

for ii = 1:length(flist)
    file=flist{ii};

    disp(file);

    texture3D=ncread(file,'DbzTexture3D');
    convectivity3D=ncread(file,'Convectivity3D');
    refl3D=ncread(file,'Dbz3D');
    part3D=ncread(file,'Partition3D');

    highInd=find(refl3D>reflThresh);
    highText=texture3D(highInd);
    highConv=convectivity3D(highInd);
    highRefl=refl3D(highInd);
    highPart=part3D(highInd);

    textureAll=cat(1,textureAll,highText);
    convectivityAll=cat(1,convectivityAll,highConv);
    dbzAll=cat(1,dbzAll,highRefl);
    part3dAll=cat(1,part3dAll,highPart);
end

%% Save data
if saveData
    save([outdir,'texture_',num2str(reflThresh),'dBZ_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'textureAll','-v7.3');
    save([outdir,'convectivity_',num2str(reflThresh),'dBZ_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'convectivityAll','-v7.3');
    save([outdir,'dbz_',num2str(reflThresh),'dBZ_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'dbzAll','-v7.3');
    save([outdir,'part_',num2str(reflThresh),'dBZ_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'part3dAll','-v7.3');
end
