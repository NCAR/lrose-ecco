function [data] = read_cloudnet(fileList,indata,startTime,endTime)

vars = fieldnames(indata);

% Read first file and figure out format
infile=fileList{1};

fileSpl=strsplit(infile,'/');
filePart=fileSpl{end};
startTimeFile=datetime(str2num(filePart(1:4)),str2num(filePart(5:6)),str2num(filePart(7:8)));
timeRead=ncread(infile,'time')';
indata.time=startTimeFile+hours(timeRead);
indata.asl=ncread(infile,'height');
indata.asl=double(repmat(indata.asl,1,length(indata.time)));
indata.TOPO=ncread(infile,'altitude');
indata.TOPO=double(repmat(indata.TOPO,1,length(indata.time)));

timeReadM=ncread(infile,'model_time')';
timeM=startTimeFile+hours(timeReadM);
aslM=double(ncread(infile,'model_height'));
temperature=ncread(infile,'temperature');

for ii=1:size(vars,1)
    try
        indata.(vars{ii})=ncread(infile,vars{ii});
    catch
        disp(['Variable ' vars{ii} ' does not exist in CfRadial file ',infile]);
        indata=rmfield(indata,vars{ii});
    end
end

timeMn=datenum(timeM);
timen=datenum(indata.time);

% Interpolate temperature
indata.TEMP=interp2(repmat(timeMn,length(aslM),1),repmat(aslM,1,length(timeM)),temperature,repmat(timen,size(indata.asl,1),1),indata.asl);
indata.TEMP=cat(2,indata.TEMP,indata.TEMP-273.15);

allVars=fieldnames(indata);

for jj=2:length(fileList)
    infile=fileList{jj};

    fileSpl=strsplit(infile,'/');
    filePart=fileSpl{end};
    startTimeFile=datetime(str2num(filePart(1:4)),str2num(filePart(5:6)),str2num(filePart(7:8)));
    timeRead=ncread(infile,'time')';
    tempTime=startTimeFile+hours(timeRead);

    indata.time=cat(2,indata.time,tempTime);

    for ii=1:size(allVars,1)
        if ~strcmp((allVars{ii}),'time') & ~strcmp((allVars{ii}),'TEMP') & ...
                ~strcmp((allVars{ii}),'asl') & ~strcmp((allVars{ii}),'TOPO')
            temp=ncread(infile,allVars{ii});
            indata.(allVars{ii})=cat(2,indata.(allVars{ii}),temp);
        end
    end

    aslt=ncread(infile,'height');
    aslt=double(repmat(aslt,1,length(timeRead)));
    indata.asl=cat(2,indata.asl,aslt);
    TOPOt=ncread(infile,'altitude');
    TOPOt=double(repmat(TOPOt,1,length(timeRead)));
    indata.TOPO=cat(2,indata.TOPO,TOPOt);

    timeReadM=ncread(infile,'model_time')';
    timeM=startTimeFile+hours(timeReadM);
    aslM=double(ncread(infile,'model_height'));
    temperature=ncread(infile,'temperature');

    timeMn=datenum(timeM);
    timen=datenum(tempTime);

    % Interpolate temperature
    TEMPtemp=interp2(repmat(timeMn,length(aslM),1),repmat(aslM,1,length(timeM)),temperature,repmat(timen,size(aslt,1),1),aslt);
    indata.TEMP=cat(2,indata.TEMP,TEMPtemp-273.15);
end

% Cut out correct time
timeInds=find(indata.time>=startTime & indata.time<endTime);
allVars=fieldnames(indata);
for ii=1:size(allVars,1)
    data.(allVars{ii})=indata.(allVars{ii})(:,timeInds);
end
end