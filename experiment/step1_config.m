function step1_config()
% Generate a configuration file for the experiment

fprintf('Generating config file for the experiment ... ');

CONFIG = struct();

% Paths
CONFIG.path.datasets = '0-datasets';
CONFIG.path.ensemble = '1-ensemble';
CONFIG.path.CVI = '2-cluster-validation';
CONFIG.path.consensus = '3-consensus-function';
CONFIG.path.presentation = '4-presentation';

% Experiment settings
CONFIG.datasetCollections = {'GENE', 'REAL'};
CONFIG.ensembleSize = 20;
CONFIG.numRepetitions = 30;

% External CVIs - a performance score
CONFIG.CVI.external = {'AMI'};

% Consensus functions
CONFIG.consFunctions = {...
    'DICLENS',...
    'LCE-CTS-SL',...
    'EAC-SL',...
    'PAC-SL',...
    'STREHL-CSPA',...
    'STREHL-HGPA',...
    'STREHL-MCLA',...
    'WEA-SL',...
    'JWEAC-SL',...
    'EAC-SL-Wn',...
    'STREHL-CSPA-Wn',...
    'DICLENS-Wn',...
    'EAC-SL-Wr',...
    'STREHL-CSPA-Wr',...
    'DICLENS-Wr'...
    };

% Parameters (consensus functions)
CONFIG.consFunctionsParams = [];

% LCE-CTS decay factor
CONFIG.consFunctionsParams.LCE_dc = 0.9;

% JWEAC
params = [];
params.WEAC_CVI = {'ALL'};
params.WEAC_unifyMeth = {'minmax'};
params.WEAC_reduceMeth = {'NONE'};
params.WEAC_reduceDim = {''};
params.WEAC_weightMeth = {'wMean2'};
params.WEAC_weightMode = {''};
CONFIG.consFunctionsParams.JWEAC = params;

% The PRA configuration without reduction step (for EAC-Wn, CSPA-Wn, and DICLENS-Wn)
params = [];
params.WEAC_CVI = {'ALL'};
params.WEAC_unifyMeth = {'minmax','range','prob','rank10'};
params.WEAC_reduceMeth = {'NONE'};
params.WEAC_reduceDim = {''};
params.WEAC_weightMeth = {'wMean2','wMin2','wVegaPons2','wVegaPons2','wRankAggreg2'};
params.WEAC_weightMode = {'', '','CLK','CBK','RRA'};
CONFIG.consFunctionsParams.PRA = params;
CONFIG.consFunctionsParams.PRA_TABLE = preparePRArConfig(params);

% The PRAr configuration (for EAC-Wr, CSPA-Wr, and DICLENS-Wr)
params = [];
params.WEAC_CVI = {'ALL'};
params.WEAC_unifyMeth = {'minmax','range','prob','rank10'};
params.WEAC_reduceMeth = {'FSKM','SPEC','LS','FEKM','ProbPCA'};
params.WEAC_reduceDim = {'DANCoFit'};
params.WEAC_weightMeth = {'wMean2','wMin2','wVegaPons2','wVegaPons2','wRankAggreg2'};
params.WEAC_weightMode = {'', '','CLK','CBK','RRA'};
CONFIG.consFunctionsParams.PRAr = params;
CONFIG.consFunctionsParams.PRAr_TABLE = preparePRArConfig(params);

CONFIG.presentation.scenarios = {'average','best','crossValid'};

save('config.mat','CONFIG');

fprintf('[OK]\n');