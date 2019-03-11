function []=Supp_Fig1_maps()

%% supplementary figure 2 - compare fiber groups


clear, close all

%% Define paths
currentPath = (fileparts(which(mfilename)));

structPath  = fullfile(currentPath,'singleSubjectData','maps.mat');
load(structPath)

%% plot mtv,vic,viso,gratio

f=figure('Color','k'); colormap gray;
[ha, pos] = tight_subplot(6,4,[.01 .03],[.1 .01],[.01 .01]);

for ii=1:length(age)
    
    % mtv
    axes(ha(4*ii-3)) %
    imagesc( map.tv{ii}),
    set(get(gca, 'Title'), 'Visible', 'on')
    set(ha(4*ii-3),'xTick',[],'yTick',[])
    cleanPlot(ha,ii,3)
        yl=ylabel(ha(4*ii-3),['Age: ',num2str(age(ii)),'y'],'Color','w','fontSize',14);
    set(yl,'position',yl.Position+[25,0,0])
    caxis([0 0.5])
    if ii==1,
        xc = round(diff(ha(4*ii-3).XLim)/2)-30;
        yc = ha(4*ii-3).YLim(1)+5;
        text(xc,yc,'MTV','color','w','fontSize',14,'fontWeight','bold')
    end
    
    % vic
    axes(ha(4*ii-2))
    imagesc(map.vic{ii})
    set(ha(4*ii-2),'xTick',[],'yTick',[])
    cleanPlot(ha,ii,2)
    caxis([0 1])
    if ii==1,
        xc = round(diff(ha(4*ii-2).XLim)/2)-10;
        yc = ha(4*ii-3).YLim(1)+5;
        text(xc,yc,'V_i_c','color','w','fontSize',14,'fontWeight','bold')
    end
    
    % viso
    axes(ha(4*ii-1))
    imagesc(map.viso{ii})
    set(ha(4*ii-1),'xTick',[],'yTick',[])
    cleanPlot(ha,ii,1)
    caxis([0 0.9])
    if ii==1,
        xc = round(diff(ha(4*ii-2).XLim)/2)-10;
        yc = ha(4*ii-1).YLim(1)+5;
        text(xc,yc,'V_i_s_o','color','w','fontSize',14,'fontWeight','bold')
    end
    
    % gratio
    axes(ha(4*ii))
    imagesc(map.g{ii})
    set(ha(4*ii),'xTick',[],'yTick',[])
    cleanPlot(ha,ii,0)
    caxis([0.65 0.85])    
    if ii==1,
        xc = round(diff(ha(4*ii-2).XLim)/2)-30;
        yc = ha(4*ii).YLim(1)+5;
        text(xc,yc,'g-ratio','color','w','fontSize',14,'fontWeight','bold')
    end
    
end
end
%%
function []=cleanPlot(ha,jj,num)

set(ha(4*jj-num),'xTick',[],'yTick',[])
box off
hAxes = ha(4*jj-num);
hAxes.XRuler.Color = 'k';
hAxes.YRuler.Color = 'k';
end