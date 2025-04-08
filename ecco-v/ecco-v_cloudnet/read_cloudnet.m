function [data] = read_cloudnet(fileList,indata,startTime,endTime)

vars = fieldnames(indata);

% Read first file and figure out format
infile=fileList{1};

startTimeFile=datetime(startTime.Year,startTime.Month,startTime.Day);
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
indata.TEMP=indata.TEMP-273.15;

% Cut out correct time
timeInds=find(indata.time>=startTime & indata.time<=endTime);
allVars=fieldnames(indata);
for ii=1:size(allVars,1)
    data.(allVars{ii})=indata.(allVars{ii})(:,timeInds);
end

end