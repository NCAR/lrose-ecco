function data=loadMRMSmonths(indir,inList,cats,loadVars)

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
    data.ValidCount=data.ValidCount+ncread(infile,'ValidCount');
    data.TotalCount=data.TotalCount+ncread(infile,'TotalCount');

    % Loop through categories
    for jj=1:length(cats)
        % Loop through variables
        for kk=1:length(loadVars)
            if ii==1
                data.(cats{jj}).(loadVars{kk})=zeros(length(data.lon),length(data.lat),24);
            end
            data.(cats{jj}).(loadVars{kk})=data.(cats{jj}).(loadVars{kk})+ncread(infile,[cats{jj},loadVars{kk}]);
        end
    end

end