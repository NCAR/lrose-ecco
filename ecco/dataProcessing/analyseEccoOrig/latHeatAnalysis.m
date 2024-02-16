% Read gpm data and display

close all
clear all

startDate=datetime(2015,6,1);
endDate=datetime(2015,7,17);

addpath(genpath('~/git/lrose-test/convstrat/dataProcessing/utils/'));

indirLH='/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/latentHeating/';
indirRad='/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/conv_strat/';

figdir=['/scr/cirrus1/rsfdata/projects/convstrat/mdv/gpm/pecan/plots/latHeat/'];

flist=makeFileList(indirRad,startDate,endDate,'20YYMMDDxhhmmss',1);

belowAll=[];
aboveAll=[];

for ii = 1:length(flist)
    fileAll=flist{ii};
    fileIn=fileAll(end-33:end);

    disp(fileIn);

    alt=ncread([indirRad,fileIn],'z2');
    zeroDeg=ncread([indirRad,fileIn],'ShallowHt');

    conv=ncread([indirRad,fileIn],'Convectivity3D');
    refl=ncread([indirRad,fileIn],'Dbz3D');
    lh=ncread([indirLH,fileIn],'latentHeating');
        
    % Filter out data above and below zero degree level
    altSurf=repmat(alt',size(refl,2),1);
    altMat=repmat(altSurf,1,1,size(refl,1));
    altMat=double(permute(altMat,[3,1,2]));

    zeroMat=repmat(zeroDeg,1,1,length(alt));

    convBelow=conv;
    convBelow(altMat>=zeroMat)=nan;
    convAbove=conv;
    convAbove(altMat<zeroMat)=nan;

    reflBelow=refl;
    reflBelow(altMat>=zeroMat)=nan;
    reflAbove=refl;
    reflAbove(altMat<zeroMat)=nan;

    lhBelow=lh;
    lhBelow(altMat>=zeroMat)=nan;
    lhAbove=lh;
    lhAbove(altMat<zeroMat)=nan;

    below=cat(2,reshape(convBelow,[],1),reshape(reflBelow,[],1),reshape(lhBelow,[],1));
    below(any(isnan(below),2),:)=[];

    belowAll=cat(1,belowAll,below);

    above=cat(2,reshape(convAbove,[],1),reshape(reflAbove,[],1),reshape(lhAbove,[],1));
    above(any(isnan(above),2),:)=[];

    aboveAll=cat(1,aboveAll,above);
end

%% Plot
close all
% Below
figure('Position',[100 100 1200 600],'DefaultAxesFontSize',12)
subplot(1,2,1)
scatter(belowAll(:,1),belowAll(:,3));
xlim([0 1])
ylim([-10 40])
xlabel('Below Convectivity')
ylabel('Below Latent Heating')

subplot(1,2,2)
scatter(belowAll(:,2),belowAll(:,3));
xlim([10 60])
ylim([-10 40])
xlabel('Below Reflectivity')
ylabel('Below Latent Heating')

% Above
figure('Position',[100 100 1200 600],'DefaultAxesFontSize',12)
subplot(1,2,1)
scatter(aboveAll(:,1),aboveAll(:,3));
xlim([0 1])
ylim([-10 40])
xlabel('Above Convectivity')
ylabel('Above Latent Heating')

subplot(1,2,2)
scatter(aboveAll(:,2),aboveAll(:,3));
xlim([10 60])
ylim([-10 40])
xlabel('Above Reflectivity')
ylabel('Above Latent Heating')

%% hist

close all
% Below
figure('Position',[100 100 1200 600],'DefaultAxesFontSize',12)
subplot(1,2,1)
hist3([belowAll(:,1),belowAll(:,3)],'CdataMode','auto','Ctrs',{0:0.1:1 -5:1:15})
view(2)
xlabel('Below Convectivity')
ylabel('Below Latent Heating')

subplot(1,2,2)
hist3([belowAll(:,2),belowAll(:,3)],'CdataMode','auto','Ctrs',{10:5:60 -5:1:15})
view(2)
xlabel('Below Reflectivity')
ylabel('Below Latent Heating')

% Above
figure('Position',[100 100 1200 600],'DefaultAxesFontSize',12)
subplot(1,2,1)
hist3([aboveAll(:,1),aboveAll(:,3)],'CdataMode','auto','Ctrs',{0:0.1:1 -5:1:15})
view(2)
xlabel('Above Convectivity')
ylabel('Above Latent Heating')

subplot(1,2,2)
hist3([aboveAll(:,2),aboveAll(:,3)],'CdataMode','auto','Ctrs',{10:5:60 -5:1:15})
view(2)
xlabel('Above Reflectivity')
ylabel('Above Latent Heating')
