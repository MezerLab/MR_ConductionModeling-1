# Modeling conduction from g-ratio #

This repository includes the code and dara required to reporoduce the figure in:
*"Modeling conduction delays in the corpus callosum using MRI-measured g-ratio"
Berman S., Filo S., Mezer A.A.. NeuroImage (2019).* 

The pipeline and methods used inthe paper are described below.

## Analysis steps and requirements ##

For modelling the conduction callosal tracts using g-ratio, we need:

### 1. g-ratio maps ###
We calculated g-ratio using:
1. MTV as MVF, calculated with mrQ [https://github.com/mezera/mrQ]) 
2. NODDI parameters, calculated using AMICO [https://github.com/daducci/AMICO]
3. The formula for the calculation as described in: Stikov, N., Campbell, J. S., Stroh, T., Lavelée, M., Frey, S., Novek, J., ... & Leppert, I. R. (2015). In vivo histology of the myelin g-ratio with magnetic resonance imaging. Neuroimage, 118, 397-405.‏
> FVF = MVF + (1-MVF)(1-Viso)Vic
> 
> g = sqrt(1-(MVF/FVF)).

Examples of (slices of) g-ratio maps can be seen *../MR_ConductionModeling/Figures/Supp_Fig1_maps.m*

### 2. Corpus Callosum segmentation ###
1. We performed whole-brain probablistic tractography using mrTrix's anatomicallly constrained tractography [https://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/act.html].
 We use the command: ['/opt/mrtrix3/bin/tckgen ' csdFile ' ' tckNew ' -act ' t1w5ttOUT ' -seed_gmwmi ' GWinterface ' -backtrack -cutoff 0.1 -crop_at_gmwmi -select ' tracksNum ' -maxlength ', '200']

2. Then we used AFQ to segment the callosal tracts. 
   - First run dtiInit on the difusion data: [https://github.com/vistalab/vistasoft/tree/master/mrDiffusion/dtiInit]
   - Then run AFQ: [https://github.com/yeatmanlab/AFQ]. AFQ will take as input
     * The ACT-generated  tracography
     * The g-ratio map. 
     * The dtiInit-generated dt6.mat file.
   - The AFQ will save the separate callosal tract as fg files. 
3. Finally we reSaved the fg files after sampling g-ratio per streamline.
 See an exmaple for sampling gratio in the white matter in *../MR_ConductionModeling/Analysis/Sample_g_along_strmlns.m*

Examples of the sampled tracts can be found in *../MR_ConductionModeling/Figures/Fig2_CCfibers.m*


### 3. Simulation of action potential conduction along white matter ###

We use the simulation imlemented by David Attwell's lab: [https://github.com/AttwellLab/MyelinatedAxonModel] 

An example of our use of this code can be found in *../MR_ConductionModeling/Analysis/RunModel.m*

### 4. Simulation of LFP signal from input latency ###

We use the simulation written by Hermes, Nguyen and Winawer (2017, PLOS Biology)

The original code is available in: [https://github.com/WinawerLab/BOLD_LFP]

For our adaptation of a small part of the code, used to derive LFP from a distribution of latencies (over streamline) see: *../MR_ConductionModeling/Analysis/simLFP.m*


Shai Berman, Mezer Lab, 2019 (c)
