%%  This an example of the simulation of LFP from latecies, for a single subjects
%   We use the simulation written by Hermes, Nguyen and Winawer (2017, PLOS Biology)   
%   The original code is available in: [https://github.com/WinawerLab/BOLD_LFP]

% Written by Shai Berman, Mezer Lab, 2018
%% Define paths

currentPath = fileparts(which(mfilename));

subPath     = fullfile(fileparts(currentPath), 'Figures','singleSubjectData');
fgs_path    = fullfile(subPath,'fgs');
fgNames     = { 'CC_Occipital_clean_statsMedian_medial','CC_Motor_clean_statsMedian_medial','CC_Ant_Frontal_clean_statsMedian_medial'};

bioSim_file = fullfile(fileparts(currentPath), 'Figures','simResults','CVsim_BioRange.mat');
load(bioSim_file)

%% Simulation params

dt  = 10^-3; % time steps
T   = 0.3;   % trial time
t   = dt:dt:T;
tau = 0.010;  % time constant of leaky integrato (seconds)
  
dinit = 1.72;

%% for each fiber tract, calculate the LFP signal
for f=1:length(fgNames)
    
    clear cv L latencies ts ts_integrated lfp 
    
    % 1. Create the input for the LFP simulation
    
    % 1.1. get gratio per streamline
    fg = fgRead(fullfile(fgs_path,[fgNames{f},'.mat']));
    tmp=cellfun(@(x) x.name, fg.params,'UniformOutput',0);
    ind = find(contains(tmp,'gratio'));
    g = fg.params{ind}.stat;  
    
    % 1.2. Find the velocity of each streanline, based on its gratio    
    ind     = find(simRes.d==dinit);
    gtmp    = simRes.g(ind);
    cvtmp   = simRes.CV(ind);
    Theta   = [];
    for ll = 1:length(g)
        [~ , loc] = min(abs(gtmp-g(ll)));
        Theta(ll) = cvtmp(loc);
    end
    Theta(isnan(g)) = nan;
    
    % 1.3. Create the latency of each streamline, based on its velocity and length
    lengths = @(x) sum( sqrt( sum(((diff(x')).^2)')));
    L = cellfun(lengths, fg.fibers);
    latencies = L./(Theta') ;
    latencies(latencies<1)=1;
    
    % 2.  Simulate input to a leaky integrating neuron, based on the
    %     latencies above. We used an existing noisy input from the original
    %     code repository. 
    ts = CreateSummed_inputs(latencies);
    
    % 3. Integrate over the time series to simulate a leaky integrating neuron.
    ts_integrated(1,:) = ts(1,:);
    for jj = 1:length(t)-1
        dIdt = (ts(jj,:) - ts_integrated(jj,:)) / tau;   % rate of change in current
        dI = dIdt * dt; % stepwise change in current
        ts_integrated(jj+1,:) = ts_integrated(jj,:) + dI; % current at next time point
    end
    
    % 4. Sum the timeseries:
    %    LFP is the sum of the time varying membrane potential in each neuron. 
    lfp_fun   = @(x) sum(x,2);
    lfp = lfp_fun(ts_integrated);
    %    Demean to center baeline around 0.
    lfp_all(f,:) = lfp - mean(lfp(100:end));
     
end
%% plot the steps

figure,

subplot(3,1,1),
imagesc(ts(1:50,:)')
set(gca,'xTick',[],'yTick',[0,500,1000])
ylabel('Neuron'),
c=colorbar;
ax = gca; yax = ax.YAxis; yax.Exponent = 3;
title('White noise with input in t=IHTT','fontWeight','normal')

subplot(3,1,2),
imagesc(ts_integrated(1:50,:)')
set(gca,'xTick',[],'yTick',[0,500,1000])
ylabel('Neuron'),
c=colorbar;
ax = gca; yax = ax.YAxis; yax.Exponent = 3;
title('Leaky integration','fontWeight','normal')

subplot(3,1,3),  
lfptmp = squeeze(lfp_all(2,:));
lfptmp = lfptmp/max(lfptmp);   
findpeaks(lfptmp(1:50),'Annotate','extents','WidthReference','halfheight','NPeaks',1, 'MinPeakHeight',0.9);
set(gca,'xTick',[0:10:50],'yTickLabel',{})
xlabel('Time (ms)')
ylim([-0.05,1.1])
set(gca,'FontSize',16)
title('LFP time series','fontWeight','normal'),
