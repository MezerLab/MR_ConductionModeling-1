% This script reqire vistasoft to run propertly: [https://github.com/vistalab/vistasoft]

%% initial param space
clear, close all

%% Define paths

currentPath = fileparts(which(mfilename));

LFP_file    = fullfile(currentPath,'AllSubjectsData','StrmlnLFP_aboitiz.mat');
load(LFP_file)

bioSim_file = fullfile(currentPath, 'simResults','CVsim_BioRange.mat');
load(bioSim_file)

addpath(genpath(fileparts(currentPath)))

%% General plot parameters
fgNames ={'Occipital','Motor','Ant-Frontal'};

% general params
c = colormap('lines');
cmap = [c(3,:); c(5,:);c(6,:)]; pause(1)  
M = length(fgNames);
positions = linspace(1,M*3,M);
cl= c([4,2],:);

% Remove subjects with bad fsl unwarp (causing bad CC tracts)
indY = find(Age<50 & (ID~=36 | ID~=51));
indO = find(Age>=50 & (ID~=36 | ID~=51));
 
figure,
set(gcf,'position',[588   267   900   801])

%% 1. plot lfp time series

subplot(2,2,1),hold on,
for f =1:3
    
    % young 
    dataY = squeeze(lfp_all(f,indY,:));
    boundedline(1:size(dataY,2),nanmean(dataY),std(dataY),'cmap',0.8*cmap(f,:),'alpha')
    h(2*f-1) = plot(1:size(dataY,2),nanmean(dataY),'--','color',0.8*cmap(f,:),'lineWidth',3);
    
    % old
    
    dataO = squeeze(lfp_all(f,indO,:));
    boundedline(1:size(dataO,2),nanmean(dataO),std(dataO),'cmap',cmap(f,:),'alpha')
    h(2*f) = plot(1:size(dataO,2),nanmean(dataO),'-','color',cmap(f,:),'lineWidth',3);
    
 
end
xlim([5 40]),ylim([0,1.1])
xlabel('Time (ms)'),ylabel('Normalized LFP signal')
box on, grid on
set(gca,'fontSize',14)
axPos = get(gca,'position');

%% 2. afq latencies: calculate median latency according to AFQ core values

subplot(2,2,2), hold on
for  f=1:length(fgNames)
    h(f)= scatter(latencies_lfp(f,:),latencies_afq(f,:),50,cmap(f,:),'filled','markerEdgeColor','k','MarkerFaceAlpha',0.5);
end
xlabel('LFP peak time (ms)'),ylabel('<Latency>_t_r_a_c_t _c_o_r_e (ms)')
axis([10 32 5 22]),grid on,
legend(h,fgNames,'location','southeast','box','off')
set(gca,'fontSize',14),box on

axPos2 = get(gca,'position');% [left bottom width height]

% calculate correlation
nanInd = find(~isnan(latencies_lfp(:)));
r_strVcore = corrcoef(latencies_lfp(nanInd),latencies_afq(nanInd));
mdl = fitlm(latencies_lfp(nanInd),latencies_afq(nanInd));

disp('R^2')
r_strVcore(2)^2

%% 3. Peak time
subplot(2,2,3), hold on

xy =   latencies_lfp(:,indY);  gry = repmat([1,2,3]',1,length(xy));
xo =   latencies_lfp(:,indO);  gro = repmat([1,2,3]',1,length(xo));

boxplot(xy(:),gry(:),'Notch','on','positions',positions,'Widths',1),       pause(1)
boxplot(xo(:),gro(:),'Notch','on','positions',positions+1.5,'Widths',1);   pause(1)
hObj=prettyboxplot(xy(:),xo(:),gry(:),gro(:),cl,positions);                     pause(1)

set(gca,'xTick',positions+0.75,'xTickLabel',fgNames,'fontSize',14),
ylabel('Peak time (ms)'),  xlim(minmax(positions)+[-1.5,3]),
ylim(minmax(latencies_lfp(:))+[-2,2]), grid on


for f=1:length(fgNames)
    [h,p_t(f),~,stat] = ttest2(xy(f,:),xo(f,:),'varType','unequal','tail','left');
    t_t(f)=stat.tstat;
    if h==1;
        scatter(positions(f)+0.75,max(latencies_lfp(f,:))+1,80,'*','k'),  
        psave1(f)=p_t(f);
        tsave(f)=stat.tstat;  
        df(f)=stat.df;
    end
end

axPos3 = get(gca,'position');% [left bottom width height]
newPos = [axPos(1),axPos3(2),axPos(3:4)];
set(gca,'position', newPos);
legend(hObj,'Young','Old')%,'box','on')
set(gca,'yTick',12:4:28)
 p_corr_t = mafdr(p_t,'BHFDR',true);
disp('peak time')
p_t
t_t
df

% anova
y = [xy(:);xo(:)];
g1 = [ones(size(xy(:))); 2*ones(size(xo(:)))];
g2 = [gry(:) ; gro(:)];
[p_an,tbl,stat,terms]=anovan(y,{g1,g2},'varnames',{'Age','Tract'});
% results = multcompare(stat,'Dimension',[1 2]);
disp(p_an)
%% 4. LFP width
subplot(2,2,4), hold on

xy =   width_lfp(:,indY); gry = repmat([1,2,3]',1,length(xy));
xo =   width_lfp(:,indO); gro = repmat([1,2,3]',1,length(xo));

boxplot(xy(:),gry(:),'Notch','on','positions',positions,'Widths',1),       pause(1)
boxplot(xo(:),gro(:),'Notch','on','positions',positions+1.5,'Widths',1);   pause(1)
prettyboxplot(xy(:),xo(:),gry(:),gro(:),cl,positions);                     pause(1)

set(gca,'xTick',positions+0.75,'xTickLabel',fgNames,'fontSize',14),
ylabel('LFP width (ms)'),  
xlim(minmax(positions)+[-1.5,3]),
ylim(minmax(width_lfp(:))+[-1,1]), grid on

for f=1:length(fgNames)
    [h,p_w(f),c,stat] = ttest2(xy(f,:),xo(f,:),'varType','unequal','tail','left');
    t_w(f)=stat.tstat;
    if h==1;  
        scatter(positions(f)+0.75,max(width_lfp(:))+0.5,80,'*','k'),
        psave2(f)=p_w(f);
        tsave(f)=stat.tstat;
        df_w(f) = stat.df;
    end
end
axPos4 = get(gca,'position');% [left bottom width height]
newPos = [axPos2(1),axPos4(2),axPos(3:4)];
set(gca,'position', newPos);
set(gca,'yTick',10:2:14)
p_corr_w = mafdr(p_w,'BHFDR',true);
disp('Width')
p_w
t_w
df_w  
 
% anova
y = [xy(:);xo(:)];
g1 = [ones(size(xy(:))); 2*ones(size(xo(:)))];
g2 = [gry(:) ; gro(:)];
[p_an,tbl,stat,terms]=anovan(y,{g1,g2},'varnames',{'Age','Tract'});

disp(p_an)
% results = multcompare(stat,'Dimension',[1 2]);
