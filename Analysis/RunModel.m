%% Requirements:

% This script calls the Code used to simulate the action potential in
% myelinated axons by Arancibia-Carcamo, Ford, Cossell, Ishida, Tohyama &
% Attwell (2017) eLife: [https://github.com/AttwellLab/MyelinatedAxonModel]



%% Directory of this file
clear,

addpath(genpath('.../MyelinatedAxonModel'))
out_dir = '';
if ~isdir(out_dir)
    mkdir(out_dir)
end

%% General changes

% Produce parameters for default optic nerve model.
par = Carcamo2017OpticNerveAxon();

% Membrane and myelin capacitance (Guy et al, 2016)
par.intn.elec.pas.cap.val        = 0.45; %  uF/cm2
par.myel.elec.pas.cap.val        = 0.45; %  uF/cm2

%% Run the model for different g and ds.
for runIdx=1:2
    if runIdx==1
        % run the simulation in a wide range of axon diameter values.
        out_file = [out_dir,'/CVsim_fullSpace.mat'];
        
        % The myelinated axons diameter in the corpus callosum can range
        % from 2um to 5um.
        d_range = 0.2:0.1:5;
        D_range = 0.4:0.1:7;
        
        ParamInit = combvec(d_range, D_range);
        
        d = ParamInit(1,:);
        r=d/2;
        D = ParamInit(2,:);
        g = d./D;
        
    elseif runIdx==2
        % run the simulation in a more narrow (biological range) with a
        % higher reslolution of g-ratio values.
        
        out_file = [out_dir,'/CVsim_BioRange.mat'];
        
        % The axons diameter distribution in the corpus callosum have a peak around 1 um
        % And a long tail of axon diameter as large as 8 um.
        % Considering larger axons might have a arger effect onthe MRI signal, a weighted average of the axon diameter is close ti 2um.
        d_range = [1,2,3];
        
        % We find the g-ratio values in the corpus callosum are around 0.75.
        g_range = 0.7:0.01:0.85;
        
        ParamInit = combvec(d_range, g_range);
        d = ParamInit(1,:);
        g = ParamInit(2,:);
        r=d/2;
        D = d./g;
        
    end
    
    % The interode length is a function of the fiber diameter: Relationship
    % Between Myelin Sheath Diameter And Internodal Length In Axons Of The
    % Anterior Medullary Velum Of The Adult Rat M. Ibrahim ‘, A.M. Butt A, *,
    % M. Berry B
    L = 117+30*D; %
    
    % get relevant parameter for ssetting numbber of lamellae
    PeriAxon_Space   = (10^(-3))*par.myel.geo.peri.value.vec;
    Period           = (10^(-3))*par.myel.geo.period.value;
    Nlamellae = round( (((r./g -r-PeriAxon_Space(1,2))/Period *2)+1)/2 );
    
    %% call the model simulation
    
    for ii=length(d):-1:1
        if Nlamellae(ii)<=0;    continue,   end
        
        ResfileName = fullfile(out_dir, ['CC_d',num2str(d(ii)),'_g',num2str(g(ii)),'.mat']);
        if exist(ResfileName,'file'),  continue,   end
        
        %%%% update axon diameter %%%%
        %%% internode %%%
        par.intn.geo.diam.value.vec(:)  =  d(ii);
        par.intn.seg.geo.diam.value.vec =  repmat(par.intn.geo.diam.value.vec, 1, par.geo.nintseg);   % 50x66 values value
        %%%   node   %%%
        par.node.geo.diam.value.vec(:)  =  d(ii);
        par.node.seg.geo.diam.value.vec =  repmat(par.node.geo.diam.value.vec, 1, par.geo.nnodeseg);   % 50x66 values value
        
        %%%%% update internode length accordingly %%%%
        par.intn.geo.length.value.vec(:)   =   L(ii);
        par.intn.seg.geo.length.value.vec = repmat(par.intn.geo.length.value.vec / par.geo.nintseg, 1, par.geo.nintseg); % 50x66 values valu
        
        %%%%%  update g-ratio %%%%%%
        par.myel.geo.numlamellae.value.vec(:) = Nlamellae(ii);
        
        %%%%% run the model %%%%%%
        Model(par,ResfileName);
        % Note that in some cases we might need to modify the stimulation:  par.stim.amp.value=[];
        
    end
    % end
    %% save results
    
    calcMethod = 'max';
    nodes = [20, 30];
    kk=0;
    for ii=1:length(d)
        if Nlamellae(ii)<0;    continue,   end
        
        ResfileName = fullfile(out_dir, ['CC_d',num2str(d(ii)),'_g',num2str(g(ii)),'.mat']);
        if ~exist(ResfileName,'file'),  continue,   end
        
        load(ResfileName)
        dt =  TIME_VECTOR(2)-TIME_VECTOR(1);
        vel = velocities(MEMBRANE_POTENTIAL, INTERNODE_LENGTH,dt,nodes,calcMethod);
        
        if isinf(vel)
            vel = nan;
        end
        kk=kk+1;
        simRes.CV(kk) = vel;
        simRes.d(kk) = d(ii);
        simRes.g(kk) = g(ii);
        simRes.D(kk) = D(ii);
        simRes.L(kk) = L(ii);
    end
    
    save(out_file,'simRes')
end