function step3_exportScores()
% Export scores (averaged over multiple runs for each dataset) to csv file
% ready for Bayesian analysis in Python (baycomp).


fprintf('Exporting scores to CSV for baycomp ... ');

saveFolder = 'baycomp-import';
savePrefix = 'scores';


% Load configuration
CONFIG = load('config.mat');
CONFIG = CONFIG.CONFIG;

% Datasets info
DATA_INFO = load([CONFIG.path.datasets,filesep,'datasets_info.mat']);
DATA_INFO = DATA_INFO.DATA_INFO;
datasetCollections = fieldnames(DATA_INFO);
datasetCollections_num = length(datasetCollections);

% Consensus functions
consFunctions = CONFIG.consFunctions;
consFunctions_num = length(consFunctions);

% External validity indices
CVI_ext = CONFIG.CVI.external;
CVI_ext_num = length(CVI_ext);


path_saveResults = [CONFIG.path.presentation,filesep,saveFolder];
[~,~,~] = mkdir(path_saveResults);


%--------------------------------------------------------------------------
% Load scores
SCORES = load([CONFIG.path.presentation,filesep,'SCORES.mat']);
SCORES = SCORES.SCORES;

scenarios = CONFIG.presentation.scenarios;
scenarios_num = length(scenarios);


EXPORT = [];

for dataColl_i = 1:datasetCollections_num
    datasetCollection = datasetCollections{dataColl_i};
    datasetNames = fieldnames(DATA_INFO.(datasetCollection));
    
    for eCVI_i = 1:CVI_ext_num
        eCVI = CVI_ext{eCVI_i};
        
        % Scenario
        for scenario_i = 1:scenarios_num
            scenario = scenarios{scenario_i};
                               
            scores = SCORES.(datasetCollection).(eCVI).(scenario).mean;            
            fileOutSuffix = ['-',datasetCollection,'-',eCVI,'-',scenario];
                        
            % Print to file
            fname = [savePrefix,fileOutSuffix,'.txt'];
            fid = fopen([path_saveResults,filesep,fname],'w');
            
            for consFun_i = 1:length(consFunctions)
                consFunction = consFunctions{consFun_i};
                fprintf(fid,'%s\n',consFunction);
                
                for data_i = 1:length(datasetNames)
                    fprintf(fid, '    %s %.4f\n', datasetNames{data_i},scores(data_i,consFun_i));
                end
            end
            
            fclose(fid);
        end 
    end    
end
fprintf('[OK]\n');