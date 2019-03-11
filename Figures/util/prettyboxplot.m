function [hObj]=prettyboxplot(x1,x2,gr1,gr2,cmap,positions)


% Add color to boxes
h = findobj(gca,'Type','Line','-and','Tag','Box');

count = 1;
for p = length(h):-1:1 % Boxes handles are ordered opposite to their order of creation
    x = h(p).XData;
    y = h(p).YData;
   % patch(x,y,cmap(count,:),'FaceAlpha',0.8)
    patch(x,y, 0.6*[1,1,1])
    h(p).LineWidth = 1.5;
    h(p).Color = [0 0 0];
    count = count + 1;
end


% Change line width
h = findobj(gca,'Type','Line','-not','Tag','Box');
for p = 1:length(h)
    h(p).LineWidth = 1.5;
end

% Change median line color
h = findobj(gca,'Type','Line','-and','Tag','Median');
for p = 1:length(h)
    h(p).Color = [0 0 0];
end

% Move the color patches backward
if ~notDefined('x1')
set(gca,'children',flipud(get(gca,'children')))
% Add individual data points
if length(positions)>10
    sz=10;
else
    sz=30;
end
hold all
for ii = 1:length(positions)
    % young
    dataTmp = x1(gr1==ii)';
    jitter = randn(1,size(dataTmp,2))/15;
    h = scatter(positions(ii)+jitter, dataTmp, sz, cmap(1,:),'o','filled','MarkerEdgeColor','k');
    h.MarkerFaceAlpha = 0.5;
    % old
    dataTmp = x2(gr2==ii)';
    jitter = randn(1,size(dataTmp,2))/15;
    j = scatter(positions(ii)+1.5+jitter, dataTmp, sz, cmap(end,:),'o','filled','markerEdgeColor','k');
    j.MarkerFaceAlpha = 0.5;
end
hObj(1)=h; hObj(2)=j;
end