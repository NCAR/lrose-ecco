% Compare convStrat output with lightning data

clear all;
close all;

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/'));

startTime=datetime(2015,6,1,0,0,0);
endTime=datetime(2015,7,17,0,0,0);

% startTime=datetime(2015,6,1,0,0,0);
% endTime=datetime(2015,6,10,0,0,0);

saveData=1;

indir1='/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/input/';
indir2=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/conv_strat/'];

outdir=['/scr/cirrus1/rsfdata/projects/convstrat/analysis/gpmPECAN/'];

flist=makeFileList(indir2,startTime,endTime,'20YYMMDDxhhmmss',1);

%% Loop through radar files

partOrigNew=[];

for ii = 1:length(flist)
    file2=flist{ii};
    file1=[indir1,file2(end-24:end-17),'/',file2(end-24:end)];

    disp(file2);

    partOrigIn=ncread(file1,'PID');
    partIn=ncread(file2,'EchoTypeComp');

    partOrigIn(partOrigIn==-1111)=nan;
    partOrigIn=round(partOrigIn./10000000);

    goodInd=find(~isnan(partOrigIn));

    partOrigNewIn=cat(2,partOrigIn(goodInd),partIn(goodInd));
    partOrigNewIn(any(isnan(partOrigNewIn),2),:)=[];

    partOrigNew=cat(1,partOrigNew,partOrigNewIn);
end

%% Save data
if saveData
    save([outdir,'gpm_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
        'partOrigNew');
end
