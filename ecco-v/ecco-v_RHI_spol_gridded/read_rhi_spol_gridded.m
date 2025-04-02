function [indata] = read_rhi_spol_gridded(infile,indata)

vars = fieldnames(indata);

% Read first file and figure out format

startTimeFile=datetime(1970,1,1);
timeRead=ncread(infile,'time')';
indata.time=startTimeFile+seconds(timeRead);
indata.Z=ncread(infile,'Z');
indata.R=ncread(infile,'R');

for ii=1:size(vars,1)
    try
        indata.(vars{ii})=ncread(infile,vars{ii});
    catch
        disp(['Variable ' vars{ii} ' does not exist in CfRadial file ',infile]);
        indata=rmfield(indata,vars{ii});
    end
end
end

