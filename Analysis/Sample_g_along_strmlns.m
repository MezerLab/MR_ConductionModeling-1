%% Sampling g along CC
% This code required a function that was very minorly adapted from vistasoft
% vistasoft [https://github.com/vistalab/vistasoft   function:dtiCreateQuenchStats.m]
% Written by Shai Berman, Mezer Lab, 2018
%%
% Define the directory with the diffusion niftis: 
input_dir  = '' ;

% load the g-ratio mao
g_file = fullfile(input_dir,'gratio.nii.gz');
g = readFileNifti(g_file);

% load a white matter mask
wm_mask_file = fullfile(input_dir,'WM_mask.nii.gz');
wm_mask =  readFileNifti(wm_mask_file);
wm_mask = logical(wm_mask.data);

g.data(~wm_mask)=nan;

% load the AFQ file containg the paths to the calloswal trast
afq_file = fullfile(input_dir,'afq.mat');
loa(afq_file)

% loop over occipital, motor, and frontal CC tracts
tractInd =[21,24,26]; 
tracts = {afq.fgnames{tractInd}};

perPointFlag = 0;
sampling_opt =  'nanmedian_med'; 

for t=1:length(tracts)
    
    % load fiber
    fgFile =afq.files.fibers.([tracts{t},'_clean']);
    fg=fgRead(fgFile{1});
    
    fg.params=[];        
    
    % Calculate the median of samples only along the medial section of each streamline
    fg = dtiCreateQuenchStats_shai(fg, 'g_Median', 'gratio', perPointFlag, g, sampling_opt, 1);
    fg = addStreamlineLength(fg);
    
    % save
    fgFileNew = fullfile(afq.sub_dirs{1},'fibers',[tracts{t},'_clean_statsMedian_medial.mat']);        % calc median param for each map and each streamline
    dtiWriteFiberGroup(fg,fgFileNew)
end
