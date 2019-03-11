%% supplementary figure 2 - compare fiber groups trajetory


clear, close all

%% Define paths
currentPath = fileparts(which(mfilename));

structPath  = fullfile(currentPath,'AllSubjectsData','CoreDataStruct_full.mat');
load(structPath)

%% General parameters
fgNames ={'Occipital','Motor','Ant-Frontal'};

BadInd = ID==51 | ID==36 ;
yInd = find(Age<50 & ~BadInd) ;
oInd = find(Age>=50 & ~BadInd);

c = colormap('lines');
cmap1 = [c(3,:); c(5,:);c(6,:)]; pause(1)  
cmap2 = [c(4,:); c(2,:)];        pause(1)  

 %% look at distribution along the tract:
figure(1), 
set(gcf,'position',[500,1,960,1090])

subplot(4,2,1),hold on, 
% calculate the different versions of g-ratio

for f = 1:length(fgNames)    
    boundedline(1:100,nanmean(g{f}(yInd,:)),std(g{f}(yInd,:)),'cmap',cmap1(f,:),'alpha')
    h(f) = plot(1:100,nanmean(g{f}(yInd,:)),'color',cmap1(f,:),'lineWidth',3);
end

xlabel('Node'), 
ylabel('$\bar{g}_{young subs}$','Interpreter','latex')
set(gca,'xTick',0:20:100,'yTick',0.68:0.04:0.82)
grid on, box on,
ylim([0.68 0.82])
set(gca,'fontSize',14)
legend(h,fgNames,'EdgeColor','w','fontSize',14)

%% look at the tract differences, as a function of nodes, for all subjects

subplot(4,2,2), hold on 
NumOfNodes =  5:5:50;
% calculate the different versions of g-ratio
for f = 1:length(fgNames)
    kk=0;
  for NIdx = 1:length(NumOfNodes)
      
      nodes=(50-NumOfNodes(NIdx)+1):(50+NumOfNodes(NIdx));
      
      datY = g{f}(yInd,nodes);
      g_mean(NIdx) = nanmean(datY(:));
      g_ste(NIdx)  = std(datY(:))/sqrt(length(yInd));
       
  end
  
  boundedline(10:10:100, g_mean, g_ste, 'cmap', cmap1(f,:),'alpha');
  plot(10:10:100, g_mean, 'color',cmap1(f,:),'lineWidth',2);
end
ylabel('$\bar{g}_{young sub \& nodes}$','Interpreter','latex')
xlabel('# Nodes (around midline)'),
grid on,   box on,
xlim([10 100])
set(gca,'fontSize',14)   

%% look at the age differences, per tract, as a function of nodes

% calculate the different versions of g-ratio
for f = 1:length(fgNames)
 
  for NIdx =1:length(NumOfNodes);
      nodes=(50-NumOfNodes(NIdx)+1):(50+NumOfNodes(NIdx));
      
      datY = g{f}(yInd,nodes);
      g_y(NIdx)     = nanmean(datY(:));
      g_y_ste(NIdx) = std(datY(:))/sqrt(length(yInd));
       
      datO = g{f}(oInd,nodes);
      g_o(NIdx)     = nanmean(datO(:));
      g_o_ste(NIdx) = std(datO(:))/sqrt(length(oInd));
  end
  subplot(4,2,2+2*f), hold on, 
  boundedline(10:10:100, g_y, g_y_ste, 'cmap', cmap2(1,:),'alpha');
  boundedline(10:10:100, g_o, g_o_ste, 'cmap', cmap2(2,:),'alpha');
  j(1) = plot(10:10:100, g_y, 'color',cmap2(1,:),'lineWidth',2);
  j(2) = plot(10:10:100, g_o, 'color',cmap2(2,:),'lineWidth',2);
  
    
  xlabel('# Nodes (around midline)'),
  ylabel('$\bar{g}_{subs \& nodes}$','Interpreter','latex')
  grid on,   box on,   xlim([10 100])
  set(gca,'fontSize',14),
  title(fgNames{f},'fontWeight','normal')
  
  subplot(4,2,2+2*f-1),hold on,
  boundedline(1:100,nanmean(g{f}(yInd,:)),std(g{f}(yInd,:)),'cmap',cmap2(1,:),'alpha')
  h(1) = plot(1:100,nanmean(g{f}(yInd,:)),'color',cmap2(1,:),'lineWidth',3);

   boundedline(1:100,nanmean(g{f}(oInd,:)),std(g{f}(oInd,:)),'cmap',cmap2(2,:),'alpha')
   h(2) = plot(1:100,nanmean(g{f}(oInd,:)),'color',cmap2(2,:),'lineWidth',3);
   xlabel('Node'),
   ylabel('$\bar{g}_{subs}$','Interpreter','latex')
   set(gca,'xTick',0:20:100,'yTick',0.68:0.04:0.82)
   grid on, box on,
   ylim([0.68 0.82])
   set(gca,'fontSize',14)
  
  if f==1, legend(h,{'Young','Old'},'EdgeColor','w','fontSize',14), end


end
