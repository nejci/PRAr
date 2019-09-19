% =========================================================================
% Weighted Cluster Ensemble Based on 
% Partition Relevance Analysis With Reduction Step
% -------------------------------------------------------------------------
% Illustrative example (see Section III.D, Fig. 1, Tables I and II)
% -------------------------------------------------------------------------
% Writen by Nejc Ilc (nejc.ilc@fri.uni-lj.si)
% 2019-09-19
% =========================================================================

%% Demo configuration
clear;
clc;

% Fix random generator's seed for easier reproduction
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);

% Settings
dataset_name = 'lca';

ensembleGenerationConfig = {...
    'random',1,2,'fixed';... % Random, 2 clusters.
    'KM',1,5,'fixed';...     % K-means, 5 clusters.
    'KVV',1,3,'fixed';...    % Spectral alg., 3 clusters.
    'SL',1,3,'fixed'};       % Single-linkage, 3 clusters.

CVIs = {'CH','SDBW','SF','DB','DNs'};

unification = 'range';
reduction = 'FSKM';
aggregation = 'wMean2';
dimEstimator = 'DANCoFit';
consensusFunction = 'WEAC-SL';


%% Load data
[X,gt] = pplk_loadData(dataset_name);
[N,D] = size(X);

% Number of clusters in the ground-truth partition
K_T = length(unique(gt));


%% Generate cluster ensemble P with M members
P = pplk_genEns(X,ensembleGenerationConfig);
M = size(P,2);

% Give names to members.
ensMemberNames = strcat(...
    'C_',num2str((1:M)'),...
    ' (',ensembleGenerationConfig(:,1),...
    ', K=',num2str([ensembleGenerationConfig{:,3}]'),')')';


%% PRAr
% 1. Validation with CVIs
[~,rawValues] = pplk_validInt(X,P,CVIs);
V = rawValues';
% Output matrix V
fprintf(1,'Matrix V with raw CVI values:\n');
V_tab = array2table(V,'VariableNames',CVIs, 'RowNames',ensMemberNames);
disp(V_tab);

% Unification (function Gamma)
% Min-optimal CVIs (the lower the value of a CVI, the better the partition)
listOfMinOptimal = {'APN', 'AD', 'ADM', 'CI', 'CON', 'DB', 'DB*','DBMOD', ...
    'FOM', 'GAMMA','SD','SDBW','SEP','SEPMAX','TAU','VAR','XB','XB*','XBMOD'};
minOptimalMask = ismember(upper(CVIs),listOfMinOptimal);
U = pplk_unifyPRM(V, minOptimalMask, unification);

% Plot U using PCA
param = [];
param.title = 'PCA of matrix U';
param.annotations = CVIs;
pplk_scatterPlot(U',[],[],param);

% Reduction (function Pi)
[R,featInd] = pplk_featureReduce(U, reduction, dimEstimator);

% Aggregation (function Omega)
w = pplk_weightPRM(R,aggregation);

% Consensus function
params = [];
params.WEAC_weights = w;
CP_PRAr = pplk_consEns(P,K_T,consensusFunction,params);


%% Consensus with PRA but without reduction
% Aggregation of full matrix U instead of the reduced R.
w_none = pplk_weightPRM(U,aggregation);

% Consensus function
params = [];
params.WEAC_weights = w_none;
CP_none = pplk_consEns(P,K_T,consensusFunction,params);


%% Consensus without PRA
% Give equal weights to ensemble members.
w_noPRA = ones(M,1);

% Consensus function
params = [];
params.WEAC_weights = w_noPRA;
[CP_noPRA,numClust] = pplk_consEns(P,K_T,consensusFunction,params);


%% Display weights, ensemble members and final (consensus) partition

% Output matrix U with aggregated weights in the last column
fprintf(1,'Matrix U with unified CVI values and aggregated weights:\n');
U_tab = array2table([U, w_none],'VariableNames',[CVIs, 'w'], 'RowNames',ensMemberNames);
disp(U_tab);

% Output matrix R with aggregated weights in the last column
fprintf(1,'Matrix R with reduced CVIs (%d) and aggregated weights:\n',numel(featInd));
R_tab = array2table([R,w],'VariableNames',[CVIs(featInd),'w'], 'RowNames',ensMemberNames);
disp(R_tab);

% Show ensemble members and consensus partitions
param = [];
param.interpreterMode = 'tex';
param.title = 'Ensemble members and consensus partitions';
param.subtitle = [ensMemberNames, 'C^P (no PRA)', 'C^P (PRA)', 'C^P (PRAr)'];
param.axisStyle = 'square';
param.colorMode = 'mixed';
param.markerSize = 7;
fig = pplk_scatterPlot(X,[P,CP_noPRA,CP_none,CP_PRAr],[],param);
fig.WindowState = 'maximized';
% Save figure as PDF
saveas(fig,'demo_PRAr_fig.eps','epsc');


%% (optional) Generate Latex code of the tables V_tab, U_tab, and R_tab
% Using https://github.com/eliduenisch/latexTable

ensMemTex = strcat('$\vect{C}_',cellstr(num2str((1:M)')),'$');

input = [];
V_tab_mod = V_tab;
V_tab_mod.Properties.RowNames = ensMemTex;
input.data = V_tab_mod;
input.tableCaption = 'Matrix $\vect{V}$ of an illustrative example.';
input.tableLabel = 'tab:example:V';
input.dataFormat = {'%.3f'};
input.tableColumnAlignment = 'c';
input.tableBorders = 0;
input.makeCompleteLatexDocument = 0;
latex = latexTable(input);
% save LaTex code as file
fid=fopen('V_tab.tex','w');
nrows = size(latex,1);
for row = 1:nrows
    fprintf(fid,'%s\n',latex{row,:});
end
fclose(fid);


U_tab_mod = addvars(U_tab,w,'NewVariableNames','w_PRAr');
U_tab_mod.Properties.RowNames = ensMemTex;
input = [];
input.data = U_tab_mod;
input.tableCaption = 'Matrix $\vect{U}$ of an illustrative example.';
input.tableLabel = 'tab:example:U';
input.dataFormat = {'%.3f'};
input.tableColumnAlignment = 'c';
input.tableBorders = 0;
input.makeCompleteLatexDocument = 0;
latex = latexTable(input);
% save LaTex code as file
fid=fopen('U_tab.tex','w');
nrows = size(latex,1);
for row = 1:nrows
    fprintf(fid,'%s\n',latex{row,:});
end
fclose(fid);


input = [];
R_tab_mod = R_tab;
R_tab_mod.Properties.RowNames = ensMemTex;
input.data = R_tab_mod;
input.tableCaption = 'Matrix $\vect{R}$ of an illustrative example.';
input.tableLabel = 'tab:example:R';
input.dataFormat = {'%.3f'};
input.tableColumnAlignment = 'c';
input.tableBorders = 0;
input.makeCompleteLatexDocument = 0;
latex = latexTable(input);
% save LaTex code as file
fid=fopen('R_tab.tex','w');
nrows = size(latex,1);
for row = 1:nrows
    fprintf(fid,'%s\n',latex{row,:});
end
fclose(fid);



