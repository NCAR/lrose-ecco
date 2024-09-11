function [data] = read_apr3_3D_nc(fileList,indata,startTime,endTime)

vars = fieldnames(indata);

% Read first file and figure out format
infile=fileList{1};

startTimeFile=datetime(1970,1,1);
timeRead=ncread(infile,'lores_scantime')';
indata.time=startTimeFile+seconds(timeRead);
indata.lores_lat=ncread(infile,'lores_lat');
indata.lores_lon=ncread(infile,'lores_lon');
indata.lores_roll=ncread(infile,'lores_roll');
indata.lores_alt3D=ncread(infile,'lores_alt3D');

for ii=1:size(vars,1)
    try
        indata.(vars{ii})=ncread(infile,vars{ii});
    catch
        disp(['Variable ' vars{ii} ' does not exist in CfRadial file ',infile]);
        indata=rmfield(indata,vars{ii});
    end
end

% Organize dimensions into the order beam, time, range
allVars=fieldnames(indata);
for ii=1:size(allVars,1)
    if strcmp((allVars{ii}),'time')
        data1.time=permute(indata.time,[2,1]);
    elseif length(size(indata.(allVars{ii})))==3
        data1.(allVars{ii})=permute(indata.(allVars{ii}),[2,3,1]);
    else
        data1.(allVars{ii})=indata.(allVars{ii});
    end
end

% Read rest of files
for jj=2:length(fileList)
    indata=[];
    infile=fileList{jj};
    for ii=1:size(allVars,1)
        if strcmp((allVars{ii}),'time')
            timeRead=ncread(infile,'lores_scantime')';
            indata.time=startTimeFile+seconds(timeRead);
        else
            indata.(allVars{ii})=ncread(infile,allVars{ii});
        end
    end
    % Don't read data if range dimension does not agree
    if size(data1.lores_alt3D,3)~=size(indata.lores_alt3D,1)
        disp(['Skipping file ',infile,'because dimensions do not agree.']);
        continue
    end
    % Organize dimensions into the order beam, time, range
    allVars=fieldnames(indata);
    for ii=1:size(allVars,1)
        if strcmp((allVars{ii}),'time')
            data1.time=cat(2,data1.time,permute(indata.time,[2,1]));
        elseif length(size(indata.(allVars{ii})))==3
            data1.(allVars{ii})=cat(2,data1.(allVars{ii}),permute(indata.(allVars{ii}),[2,3,1]));
        else
            data1.(allVars{ii})=cat(2,data1.(allVars{ii}),indata.(allVars{ii}));
        end
    end
end

midTime=data1.time(12,:);

timeInds=find(midTime>=startTime & midTime<=endTime);
for ii=1:size(allVars,1)
    if length(size(indata.(allVars{ii})))==3
        data1.(allVars{ii})=data1.(allVars{ii})(:,timeInds,:);
    else
        data1.(allVars{ii})=data1.(allVars{ii})(:,timeInds);
    end
end

% Find correct angle
scanAng=-25:50/(size(data1.time,1)-1):25.01;
[~,nadirInd]=min(abs(scanAng'-data1.lores_roll),[],1);
nadirIndLin2D=sub2ind(size(data1.time),nadirInd,1:size(data1.time,2));

% Get data from correct angle and rename variables
data.time=data1.time(nadirIndLin2D);
data.latitude=data1.lores_lat(nadirIndLin2D);
data.longitude=data1.lores_lon(nadirIndLin2D);
data.TOPO=data1.lores_Topo_Hm(nadirIndLin2D);
data.asl=nan(size(data1.lores_zhh14,3),length(data.time));
data.DBZ=nan(size(data1.lores_zhh14,3),length(data.time));
data.VEL=nan(size(data1.lores_zhh14,3),length(data.time));
for ii=1:size(data.DBZ,1)
    altii=data1.lores_alt3D(:,:,ii);
    data.asl(ii,:)=altii(nadirIndLin2D);
    zii=data1.lores_zhh14(:,:,ii);
    data.DBZ(ii,:)=zii(nadirIndLin2D);
    vii=data1.lores_vel14c(:,:,ii);
    data.VEL(ii,:)=vii(nadirIndLin2D);
end
end

