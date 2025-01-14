% This script reqire vistasoft to run propertly: [https://github.com/vistalab/vistasoft]

%% initial param space
clear, close all

%% Define paths

currentPath = (fileparts(which(mfilename)));

structPath  = fullfile(currentPath,'AllSubjectsData','CoreDataStruct.mat');
load(structPath)

bioSim_file = fullfile(currentPath, 'simResults','CVsim_BioRange.mat');
load(bioSim_file)

addpath(genpath(fileparts(currentPath)))
%% Add the simlated velovity and latency to the data structure
dHist = [1.72, 2.81, 1.3];

% now with the simulation latency
if isfield(D,'ThetaSim'), D = rmfield(D,'ThetaSim');end
for ll = 1:length(D.gratio)
    
    dinit = dHist(D.tract(ll));
    ind     = find(simRes.d==dinit);
    gtmp    = simRes.g(ind);
    cvtmp   = simRes.CV(ind);
    
    % Add the simulation-based latency latency
    [~,loc] = min(abs(gtmp-D.gratio(ll)));
    D.ThetaSim(ll) = cvtmp(loc);
end

D.ThetaSim = D.ThetaSim';
D.ThetaSim(isnan(D.gratio)) = nan;
D.latencySim = D.Tlength./D.ThetaSim;

%% separate young and old

% Remove subjects with bad fsl unwarping (causing bad CC tracts)
BadInd = D.sub==51 |  D.sub==36;

% young
youngInd = D.age==1 & ~BadInd;
gr_young = D.tract(youngInd);
L_young = {D.gratio(youngInd);  D.ThetaSim(youngInd); D.Tlength(youngInd);  D.latencySim(youngInd)};

% old
oldInd = D.age==2 & ~BadInd;
gr_old = D.tract(oldInd);
L_old = {D.gratio(oldInd);      D.ThetaSim(oldInd);   D.Tlength(oldInd);    D.latencySim(oldInd)};

lbls = {'g-ratio','Velocity (m/s) ','Tract Length (mm)','Latency (ms)'};
hyp = {'left','right','both','left'};% right  x > y; young > old

%% plot paarameters
fgNames ={'Occipital','Motor','Ant-Frontal'};
M = length(fgNames);

cmap = colormap('lines');
cmap = [repmat(cmap([4],:),M,1);repmat(cmap([2],:),M,1)];
positions = linspace(1,M*3,M);

%% plot
figure, hold on,
set(gcf,'position',[1 1 1500 900]),

for s = 1:length(L_young)
    
    subplot(2,2,s),hold on,
    datY=L_young{s};datO=L_old{s};
    
    boxplot(datY,gr_young,'Notch','on','positions',positions,'Widths',1);      pause(1)
    boxplot(datO,gr_old,'Notch','on','positions',positions+1.5,'Widths',1);    pause(1)
    tmp=prettyboxplot(datY,datO,gr_young,gr_old,cmap,positions);               pause(1)
    
    % Add titles and labels
    set(gca,'xticklabel',fgNames ,'Fontsize',12)
    ylabel(lbls{s}),  grid on,
    xlim([positions(1)-2,positions(end)+3.5])
    ylim( minmax([datY;datO])+[-1,1].*nanstd([datY;datO]))
    
    % add siginificance symbols
    tract = unique(gr_young);
    for t = 1:length(tract)
        yt = datY(gr_young == t);
        ot= datO(gr_old == t);
        
        [sig,p(s,t),~,stat(s,t)]=ttest2(yt,ot,'varType','unequal','tail',hyp{s});
        
        if sig==1
            locx = positions(t) + 0.75;
            locy = max([yt;ot]) + 0.5*std([yt;ot]);
            scatter(locx,locy,80,'*','k'),
        end
    end
    
    if s ==1
        hObj=tmp;
        legend(hObj,'Young','Old')
    end
    set(gca,'fontSize',15)
end

%% display Statistic
tstat = reshape([stat(:).tstat],4,3);
df = reshape([stat(:).df],4,3);
for param = 1:length(lbls)
disp(lbls{param})
    disp(['   pval:          ' num2str(p(param,:))])
    pCorr =  mafdr(p(param,:),'BHFDR',true);
    disp(['   correcct pval: ' num2str(pCorr)])
    disp(['   tstat:         ', num2str(tstat(param,:))])
    disp(['   deg of free:   ' num2str(df(param,:))])    
end

%% perform Anova

for s = 1:length(L_young) % loop over measures: gratio, velocity, length, latency
      datY=L_young{s};
    datO=L_old{s};
    y = [datY;datO];
    g1 = [ones(size(datY)); 2*ones(size(datO))];
    g2 = [gr_young ; gr_old];
    [p_an,tbl,stat,terms]=anovan(y,{g1,g2},'varnames',{'Age','Tract'});
    disp(lbls{s})
    disp(p_an)     
end
% multcompare(stat,'dimension',[1 2])