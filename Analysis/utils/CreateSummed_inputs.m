function ts = ChangeSummed_inputs(latencies, plotNow)

% Maybe, I can take  one of their simulated poisson neurons, which is
% irregular, and add a firing in groups according to simulated conduction
% velocity.  For example:

%% initialize input
% this was taken from ns_script05_Fig5, line 60, where they use
% ns_simulate_data, in which the summed_inouts is created
load('/ems/elsc-labs/mezer-a/Mezer-Lab/projects/code/CiNet/Paper_Hermes_2017_PLOSBiology-master/tests/poissonInputs.mat')
maxP=max(summed_inputs(:));
% just for the gam, I'll assume that: 50 neuron reached max P at t=60, 50
% neuron reached max P at t=63, 50 neuron reached max P at t=67, 50 neuron
% reached max P at t=70,

%% number of "neurons"
numX = length(latencies);
if numX<size(summed_inputs,2)
    ts = summed_inputs(:,1:numX);
elseif numX>size(summed_inputs,2)
   numOfReps = ceil(numX/size(summed_inputs,2));
   repInput = repmat(summed_inputs,1,numOfReps);
   ts = repInput(:,1:numX);
end
%% add the "signal"
latencies = sort(round(latencies));
latencies(latencies>998)=998;
latencies(isnan(latencies))=[];
ind = sub2ind(size(ts),latencies,[1:length(latencies)]');
ts(ind)=maxP;

% make the signal last for 2 time steps. 
for ii = 1:2
    ind = sub2ind(size(ts),latencies+ii,[1:length(latencies)]');
    ts(ind)=maxP;
end
%% plot
if notDefined('plotNow')
    plotNow = 0;
end

if plotNow
    figure,
    imagesc(ts')
    xlabel('T'), ylabel('Neuron')
    colorbar, caxis([-0.1 0.5])
    title('poisson neurons - membrane potential')
    %  histogram( summed_inputs(:)) , hold on,
    %  histogram( ts(:)) , legend('input withOUT maximum','input WITH maximum')
end