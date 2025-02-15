% This script reqire vistasoft to run propertly: [https://github.com/vistalab/vistasoft]

%% initial param space
clear, close all

%% Define paths

currentPath = fileparts(which(mfilename));
DataPath    = fullfile(currentPath,'singleSubjectData');
fgs_path    = fullfile(DataPath,'fgs');

% Load a T1w image
t1w_file    = fullfile(DataPath,'t1w_ss.nii.gz');
t1w         = readFileNifti(t1w_file);

% Load AFQ
afq_path    = fullfile(DataPath,'afq.mat');
load(afq_path)

%% 1. tract core

flds = fields(afq.vals);
fgNames = {'CC_Motor_clean','CC_Occipital_clean','CC_Ant_Frontal_clean'};
fgInds = [24,21,26];

crange = [0.7 0.8];
for fb =1:length(fgInds)
    fg(fb) = fgRead([fgs_path,'/',fgNames{fb},'_D5_L4.mat']);
    TractProfile(fb) = afq.TractProfiles(fgInds(fb));
    TractProfile(fb).vals.gratio = afq.vals.gratio{fgInds(fb)}; 
    AFQ_RenderFibers(fg(fb),'tractprofile',TractProfile(fb),'val',['gratio'],'alpha',0.2,'crange',crange,'cmap','hot','newfig',fb==1)
end

zlim([-30 80]),xlim([-50,50]),ylim([-100,80])

% add a 'slice' of a T1w image for location within the brain
AFQ_AddImageTo3dPlot(t1w, [0,0,-10],[],[],[],prctile(t1w.data(t1w.data>0),[2.5,97.5]));
AFQ_AddImageTo3dPlot(t1w, [5,0,  0],[],[],[],prctile(t1w.data(t1w.data>0),[2.5,97.5]));
delete(findall(gcf,'Type','light')); 
set(gcf,'position',[1 1 1000 900]),
h=light;

% for axial view:
view([0,90])
h.Position = [10 100 90];
% sagittal side view
view([90,0])
h.Position = [10 -10 -15];

%% 2. colored streamilnes 

fgNames = {'CC_Motor_clean_statsMedian_medial', 'CC_Occipital_clean_statsMedian_medial','CC_Ant_Frontal_clean_statsMedian_medial'};

vals =[];fInds=[];
for f = 1:length(fgNames)
    fg(f) = fgRead(fullfile(fgs_path,[fgNames{f},'.mat']));
    tmp = cellfun(@(x) x.name, fg(f).params,'UniformOutput',0);
    ind = find(contains(tmp,'gratio'));
    vals = [vals,fg(f).params{ind}.stat];  
    fInds = [fInds,f*ones(1,length(fg(f).params{ind}.stat))];
end

%  To view the variance within the fiber tract, it would help to remove
%  lower values.  There aren't many streamlines
vals(vals<=0.65)=0.65;
valLims=[0.65 0.82];
for f = 1:length(fgNames)
    c=vals2colormap(vals(fInds==f),'hot',valLims );
    AFQ_RenderFibers(fg(f),'color',c, 'tubes', [0],'newfig',f==1);
end

zlim([-30 80]),xlim([-50,50]),ylim([-100,80])

% add a 'slice' of a T1w image for location within the brain
AFQ_AddImageTo3dPlot(t1w, [0,0,-10],[],[],[],prctile(t1w.data(t1w.data>0),[2.5,97.5]));
AFQ_AddImageTo3dPlot(t1w, [5,0,  0],[],[],[],prctile(t1w.data(t1w.data>0),[2.5,97.5]));
delete(findall(gcf,'Type','light')); 
set(gcf,'position',[1 1 1000 900]),
h=light;

% for axial view:
view([0,90])
h.Position = [10 100 90];
% sagittal side view
view([90,0])
h.Position = [10 -10 -15];


