function [fileList] = makeFileList_cloudnet(indir,startTime,endTime,fileFormat)
%Make list with files within time range based on the start time of the
%files
% indir: directory where the files are located (see also subdir)
% startTime, endTime: time interval for desired output file list
% fileFormat: file format of the files where the start year is denoted as
% either 19YY or 20YY, or just YY if it is a two digit year (20YY will be assumed).
% The start month is MM, the start day is DD, the
% start hour is hh, the start minute is mm, and the start second is ss.
% All other characters need to be x up to the last needed date/time digit.
% e.g. cfrad.20150714_232700.142_to_20150714_232800.056_HCR_v0_s00_el-89.98_SUR.nc
% becomes 'xxxxxx20YYMMDDxhhmmss'. Script also works without minutes and
% seconds.
% subdir is either 1 or 0. If subdir=1, search through only sub directories
% within indir. If 0, search only in indir. subdir must have format
% YYYYMMDD.

centDig=strfind(fileFormat,'20');
if ~isempty(centDig)
    century='20';
else
    centDig=strfind(fileFormat,'19');
    if ~isempty(centDig)
        century='19';
    else
        century='20';
    end
end

YYDig=strfind(fileFormat,'Y');
MMDig=strfind(fileFormat,'M');
DDDig=strfind(fileFormat,'D');
hhDig=strfind(fileFormat,'h');
mmDig=strfind(fileFormat,'m');
ssDig=strfind(fileFormat,'s');

startDate=datetime(year(startTime),month(startTime),day(startTime),0,0,0);
endDate=datetime(year(endTime),month(endTime),day(endTime),0,0,0);

allFileList=dir([indir,'*.nc']);
if isempty(allFileList)
    allFileList=dir([indir,'*.iwrf_ts']);
end

fileList={};
if ~isempty(allFileList)
    filenames={allFileList(:,:).name};
    for ii=1:length(filenames)
        fileYear=strcat(century,filenames{ii}(YYDig(1):YYDig(2)));
        fileStart=datetime(str2num(fileYear),str2num(filenames{ii}(MMDig(1):MMDig(2))),...
            str2num(filenames{ii}(DDDig(1):DDDig(2))),0,0,0);
        if fileStart>=startDate & fileStart<endDate
            fileList{end+1}=[allFileList(ii).folder,'/',allFileList(ii).name];
        end
    end
end

