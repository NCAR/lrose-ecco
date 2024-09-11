function [data1] = read_apr3_2D(infile1,indir,indata,startTime,endTime)

vars = fieldnames(indata);

% Read first file and figure out format
infile=[indir,infile1];

startTimeFile=datetime(1970,1,1);
timeRead=ncread(infile,'lores_scantime')';
indata.time=startTimeFile+seconds(timeRead);
indata.lores_alt_nav=ncread(infile,'lores_alt_nav');
indata.lores_lat=ncread(infile,'lat');
indata.lores_lon=ncread(infile,'lon');

for ii=1:size(vars,1)
    try
        indata.(vars{ii})=ncread(infile,vars{ii});
    catch
        disp(['Variable ' vars{ii} ' does not exist in CfRadial file ',infile]);
        indata=rmfield(indata,vars{ii});
    end
end

% % Organize dimensions into the order beam, time, range
% allVars=fieldnames(indata);
% for ii=1:size(allVars,1)
%     if strcmp((allVars{ii}),'time')
%         data1.time=permute(indata.time,[2,1]);
%     elseif length(size(indata.(allVars{ii})))==3
%         data1.(allVars{ii})=permute(indata.(allVars{ii}),[2,3,1]);
%     else
%         data1.(allVars{ii})=indata.(allVars{ii});
%     end
% end
% 
% midTime=data1.time(12,:);
% 
% timeInds=find(midTime>=startTime & midTime<=endTime);
% for ii=1:size(allVars,1)
%     if length(size(indata.(allVars{ii})))==3
%         data1.(allVars{ii})=data1.(allVars{ii})(:,timeInds,:);
%     else
%         data1.(allVars{ii})=data1.(allVars{ii})(:,timeInds);
%     end
% end
% 
% % Rename variables
% data.time=data1.time;
% data.alt=data1.lores_alt_nav;
% data.latitude=data1.lores_lat;
% data.longitude=data1.lores_lon;
% data.elevation=data1.lores_elevation;
% data.DBZ=data1.lores_zhh14;
% data.VEL=data1.lores_vel14c;

%data.asl=HCRrange2asl(data.range,data.elevation,data.altitude);
%data.asl=single(data.asl);
end

