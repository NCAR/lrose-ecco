% Make list with elev conv and print out times

clear all;
close all;

addpath(genpath('~/gitPriv/utils/'));

startTime=datetime(2015,6,3,9,0,0);
endTime=datetime(2015,6,3,10,0,0);

indir=['/scr/rain2/rsfdata/projects/pecan/mdv/conv_strat/new-elev/'];

figdir=['/scr/sci/romatsch/stratConv/elevList/'];

flist=makeFileList(indir,startTime,endTime,'20YYMMDDxhhmmss',1);

elevTimes=[];
volLonLatAlt=[];

for ii = 1:length(flist)
    file=flist{ii};
    
    disp(file);
    
    %% Find matching lightning file
    
    part3Din=ncread(file,'Partition3D');
        
    bw=part3Din==32;
        
    if max(max(max(bw)))
        
        lon=ncread(file,'x0');
        lat=ncread(file,'y0');
        alt=ncread(file,'z1');
        
        elevConv=regionprops3(bw,'Volume','Centroid');
        
        lonsOne=lon(round(elevConv.Centroid(:,2)));
        latsOne=lat(round(elevConv.Centroid(:,1)));
        altsOne=alt(round(elevConv.Centroid(:,3)));
                    
        volLonLatAlt=cat(1,volLonLatAlt,cat(2,elevConv.Volume,lonsOne,latsOne,altsOne));
        
        slashes=strfind(file,'/');
        lastSlash=slashes(end);
        
        fileTime=datetime(str2num(file(lastSlash+1:lastSlash+4)),str2num(file(lastSlash+5:lastSlash+6)),...
            str2num(file(lastSlash+7:lastSlash+8)),str2num(file(lastSlash+10:lastSlash+11)),...
            str2num(file(lastSlash+12:lastSlash+13)),str2num(file(lastSlash+14:lastSlash+15)));
        
        elevTimes=cat(1,elevTimes,repmat(fileTime,size(elevConv,1),1));
    end
    
end
%% Save data
% if saveData
%     save([figdir,'data_',datestr(startTime,'yyyymmdd_HHMM'),'_to_',datestr(endTime,'yyyymmdd_HHMM'),'.mat'],...
%         'areaCatPerc','countPercAll','numFeatAll','percConvWithLA','lightPerFeat','lightPerArea');
% end
