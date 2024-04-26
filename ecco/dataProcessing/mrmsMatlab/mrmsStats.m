% Statistics of ecco output

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

startTime=datetime(2022,5,2,0,0,0);
endTime=datetime(2022,6,1,0,0,0);

saveData=1;
showPlot=1;

indir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/ecco_conus/'];
outdir=['/scr/cirrus2/rsfdata/projects/nexrad-mrms/statMats/'];

flist=makeFileList(indir,startTime,endTime,'20YYMMDDxhhmmss',1);

timeBase=datetime(1970,1,1);

lon=ncread(flist{1},'x0');
lat=ncread(flist{1},'y0');
%alt=ncread(flist{1},'z2');

echoType2D.StratLow=int8(zeros(length(lat),length(lon),24));
echoType2D.StratMid=echoType2D.StratLow;
echoType2D.StratHigh=echoType2D.StratLow;
echoType2D.Mixed=echoType2D.StratLow;
echoType2D.ConvElev=echoType2D.StratLow;
echoType2D.ConvShallow=echoType2D.StratLow;
echoType2D.ConvMid=echoType2D.StratLow;
echoType2D.ConvDeep=echoType2D.StratLow;

countAll=int8(zeros(length(lat),length(lon),24));

%% Loop through radar files

for ii = 1:length(flist)
    file=flist{ii};

    disp(file);

    timeIn=ncread(file,'time');
    time=timeBase+seconds(timeIn);

    mst=time+minutes(lon.*4);
    mstHour=hour(mst);
    mstHour=repmat(mstHour',length(lat),1);

    echoType2Din=(ncread(file,'EchoTypeComp'))';

    % Loop through hours
    for jj=1:24
        % Convective stratiform echo type
        addMat=echoType2Din==14 & mstHour==jj-1;
        echoType2D.StratLow(:,:,jj)=echoType2D.StratLow(:,:,jj)+int8(addMat);
        addMat=echoType2Din==16 & mstHour==jj-1;
        echoType2D.StratMid(:,:,jj)=echoType2D.StratMid(:,:,jj)+int8(addMat);
        addMat=echoType2Din==18 & mstHour==jj-1;
        echoType2D.StratHigh(:,:,jj)=echoType2D.StratHigh(:,:,jj)+int8(addMat);
        addMat=echoType2Din==25 & mstHour==jj-1;
        echoType2D.Mixed(:,:,jj)=echoType2D.Mixed(:,:,jj)+int8(addMat);
        addMat=echoType2Din==32 & mstHour==jj-1;
        echoType2D.ConvElev(:,:,jj)=echoType2D.ConvElev(:,:,jj)+int8(addMat);
        addMat=echoType2Din==34 & mstHour==jj-1;
        echoType2D.ConvShallow(:,:,jj)=echoType2D.ConvShallow(:,:,jj)+int8(addMat);
        addMat=echoType2Din==36 & mstHour==jj-1;
        echoType2D.ConvMid(:,:,jj)=echoType2D.ConvMid(:,:,jj)+int8(addMat);
        addMat=echoType2Din==38 & mstHour==jj-1;
        echoType2D.ConvDeep(:,:,jj)=echoType2D.ConvDeep(:,:,jj)+int8(addMat);

        % Convective stratiform echo type count
        addMat=mstHour==jj-1;
        countAll=countAll+int8(addMat);
    end
end

%% Save
if saveData
    save([outdir,'mrmsStats_',datestr(startTime,'yyyymmdd'),'_to_',datestr(endTime,'yyyymmdd'),'.mat'],...
        'echoType2D','countAll','lon','lat','-v7.3');
end
