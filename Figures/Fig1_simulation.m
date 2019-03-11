
%% initial param space
clear, close all


%% plot
figure,hold on
currentPath=fileparts(which(mfilename));

% The files below were created using [https://github.com/AttwellLab/MyelinatedAxonModel]
% An example for using this code can be found in '../MR_ConductionModeling/Analysis/RunModel_BioRage.m
fullSim_file = [currentPath,'/simResults/CVsim_fullSpace.mat'];
bioSim_file  = [currentPath,'/simResults/CVsim_BioRange.mat'];

%% 1. plot simulation results
subplot(1,3,1),hold on

load(fullSim_file)
X = simRes.d;
Y = simRes.D;
Z = real(simRes.CV);

% Define a maximum velocity to plot, for visualization's sake 
% Remove data points with: high or no velocity, or axon diameter = 0.2 (the limit)
maxVel = 20; 
ind = Z>0 & Z<maxVel & X>0.2;

% Plot and coloar according to conduction velocity
scatter3(X(ind),Y(ind),Z(ind),50,Z(ind),'filled')
h=colorbar('westoutside');
colormap('hot');
% Add black circles around data points whose g-ratio~0.6
gsim = X./Y;
ind = find(abs(gsim-0.6)<0.05);
scatter3(X(ind),Y(ind),Z(ind),50,Z(ind),'filled','markerEdgeColor','k'),

% Organize the plot
axis([0.2 5 0.2 5 0 maxVel]),grid on,caxis([0 maxVel])
xlabel('d (\mum)'),ylabel('D (\mum)'),zlabel('Velocity (m/s)')
ylabel(h,'Velocity (m/s)'), view(-135,30), set(gca,'FontSize',16)
set(h,'ticks',[0,maxVel])

%% The second and third plot will use a smaller range of value:

load(bioSim_file)
cls = [0.929 0.694 0.125; 0.466 0.674 0.188 ; 0.301 0.745 0.933];

% Here  we focus i=on 3 axon diameters - the weighted averages of ABoitiz's
% ADD in the splenium, mid-body and genu of the CC.
dEx =  [1.72, 2.81, 1.3]; 

%% 2. Velocity: the effect of g in d=1:3
subplot(1,3,2),hold on, 
axis square, box on

for kk=1:length(dEx)
    dInd = find(simRes.d==dEx(kk) & simRes.g>0.5);
    p(kk)=plot(simRes.g(dInd),simRes.CV(dInd),'-','lineWidth',3,'Color',cls(kk,:));
    scatter(simRes.g(dInd),simRes.CV(dInd),20,p(kk).Color,'filled')
end

xlabel('g-ratio'),
ylabel('Velocity (m/s)'),
grid on
xlim([0.7 0.85]),
set(gca,'FontSize',16)
legend(p,{'d = 1.72\mum (Splenium)','d = 2.81\mum (Body)','d = 1.3\mum (Genu)'},'fontSize',13)

%% 3. latencyfor 10 cm. 

subplot(1,3,3),hold on,
axis square, box on

L = 100; 
for kk=1:length(dEx)
    
    dInd = find(simRes.d==dEx(kk) & simRes.g>0.5);
    p(kk)=plot(simRes.g(dInd),L./simRes.CV(dInd),'-','lineWidth',3,'Color',cls(kk,:));
     scatter(simRes.g(dInd),L./simRes.CV(dInd),20,p(kk).Color,'filled')
end

xlabel('g-ratio'),ylabel('Latency along 10cm (ms)'),grid on
set(gca,'FontSize',16)
xlim([0.7 0.85]) 

%% Set figure size 

pos=[66 ,  606,  1855,   464];
set(gcf,'position',pos)

