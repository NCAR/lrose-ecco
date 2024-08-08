function data=loadMRMSmonths(indir,inList,cats,loadVars,maskFile)

infile1=[indir,inList{1}];
data.lon=ncread(infile1,'x0');
data.lat=ncread(infile1,'y0');

% Loop throught files
for ii=1:length(inList)
    infile=[indir,inList{ii}];
    if ii==1
        data.ValidCount=zeros(length(data.lon),length(data.lat),24);
        data.TotalCount=zeros(length(data.lon),length(data.lat),24);
    end
    inCounts=ncread(infile,'ValidCountHourly');
    inCounts(isnan(inCounts))=0;
    data.ValidCount=data.ValidCount+inCounts;
    inCounts=ncread(infile,'TotalCountHourly');
    inCounts(isnan(inCounts))=0;
    data.TotalCount=data.TotalCount+inCounts;

    % Loop through categories
    for jj=1:length(cats)
        % Loop through variables
        for kk=1:length(loadVars)
            if ii==1
                data.(cats{jj}).(loadVars{kk})=zeros(length(data.lon),length(data.lat),24);
            end
            inCounts=ncread(infile,[cats{jj},loadVars{kk}]);
            inCounts(isnan(inCounts))=0;
            data.(cats{jj}).(loadVars{kk})=data.(cats{jj}).(loadVars{kk})+inCounts;
        end
    end
end

% Mask
if ~isempty(maskFile)
    load(maskFile);
    mask3D=repmat(mask,1,1,24);

    % Loop through categories
    for jj=1:length(cats)
        % Loop through variables
        for kk=1:length(loadVars)
            data.(cats{jj}).(loadVars{kk})(mask3D==1)=nan;
        end
    end
end
end