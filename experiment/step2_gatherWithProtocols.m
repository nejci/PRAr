function step2_gatherWithProtocols()
% Gather the results and compute scores under various scenarios.
%
% Aggregate dimension of PRA config considering three scenarios:
%    - average: score of PRAr config that is best on average over all datasets
%    - best: score of PRAr config that is best for each dataset
%    - crossValid: cross-validation score (leave one out)
%         1. take n-1 datasets and find PRAr config that is the best on average.
%         2. Take the score on nth dataset with this config.
% These scenarios affect only PRA/r methods (Wn/Wr).
% Scores of conventional cons. funs. are averages over repetitions.

fprintf('Gathering results and applying evaluation protocols ... ');

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

SCORES = [];

for dataColl_i = 1:datasetCollections_num
    datasetCollection = datasetCollections{dataColl_i};
    datasetNames = fieldnames(DATA_INFO.(datasetCollection));
    datasets_num = length(datasetNames);
    
    for eCVI_i = 1:CVI_ext_num
        eCVI = CVI_ext{eCVI_i};
        
        % Prepare space
        SCORES_all_mean = cell(1,consFunctions_num);
        SCORES_all_std = cell(1,consFunctions_num);
        % Scenarios (mean and std)
        SCORES_average_mean = zeros(datasets_num, consFunctions_num);
        SCORES_best_mean = zeros(datasets_num, consFunctions_num);
        SCORES_crossValid_mean = zeros(datasets_num, consFunctions_num);
        SCORES_average_std = zeros(datasets_num, consFunctions_num);
        SCORES_best_std = zeros(datasets_num, consFunctions_num);
        SCORES_crossValid_std = zeros(datasets_num, consFunctions_num);
        
        TopPRAconfigs_average = cell(1,consFunctions_num);
        TopPRAconfigs_best = cell(datasets_num,consFunctions_num);
        TopPRAconfigs_crossValid = cell(datasets_num,consFunctions_num);
                
        for consFun_i = 1:consFunctions_num
            consFunction = consFunctions{consFun_i};
            
            % Is consFunction conventional or weighted using PRA/r?
            isPRAEnabled = 0;
            numPRAConfigs = 1;
            if      strcmpi(consFunction(1:end-1),'EAC-SL-W') || ...
                    strcmpi(consFunction(1:end-1),'DICLENS-W') ||...
                    (length(consFunction)>6 && strcmpi(consFunction(1:7),'STREHL-') && ...
                    strcmpi(consFunction((end-2):(end-1)),'-W'))
                
                isPRAEnabled = 1;
                if consFunction(end) == 'n'
                    numPRAConfigs = size(CONFIG.consFunctionsParams.PRA_TABLE,1);
                elseif consFunction(end) == 'r'
                    numPRAConfigs = size(CONFIG.consFunctionsParams.PRAr_TABLE,1);
                else
                    error('Wrong name.');
                end
            end
            
            % Mean/std over repetitions for a consensus function
            score_mean_i = zeros(datasets_num, numPRAConfigs);
            score_std_i = zeros(datasets_num, numPRAConfigs);
            
            for data_i = 1:datasets_num
                datasetName = datasetNames{data_i};
                
                % Load results
                CONS = load([CONFIG.path.consensus,filesep,...
                    datasetCollection,filesep,consFunction,filesep,...
                    'CP_',datasetName,'.mat']);
                CONS = CONS.CONS;
                assert(numPRAConfigs == size(CONS.validationScores,3),'Consistency error.');
                
                score_mean_i(data_i, :) = squeeze(mean(CONS.validationScores(eCVI_i,:,:),2));
                score_std_i(data_i, :) = squeeze(std(CONS.validationScores(eCVI_i,:,:),0,2));
            end
            
            SCORES_all_mean{consFun_i} =  score_mean_i;
            SCORES_all_std{consFun_i} =  score_std_i;
                        
            % Consider scenarios if cons. fun. is with PRA/r
            if isPRAEnabled
                
                % Scenario 'average': find PRAr config that is best on average over datasets.
                % 1. Average PRAr config over datasets
                scenAvg_mean_per_config = mean(score_mean_i,1);
                % 2. Select PRAr configuration with max average score.
                % 3. Use this PRAr config for all datasets.
                % What if there are more such indices?
                % Select first (max function 2nd output), save all.
                scenAvg_bestConfigScore = max(scenAvg_mean_per_config);
                %scenAvg_bestScore_std = 
                scenAvg_bestScoreInd = bsxfun(@eq, scenAvg_bestConfigScore,scenAvg_mean_per_config);
                TopPRAconfigs_average{consFun_i} = scenAvg_bestScoreInd;
                % If there are more best configs, pick up the result of the
                % best one for each dataset
                [SCORES_average_mean(:,consFun_i), maxIdx] = max(score_mean_i(:,scenAvg_bestScoreInd),[],2);
                for data_i = 1:datasets_num   
                    SCORES_average_std(data_i,consFun_i) = score_std_i(data_i,maxIdx(data_i));
                end
                
                % Scenarios best and cross-validated
                for data_i = 1:datasets_num                                        
                    % Scenario 'best': find PRA config with best score for
                    % each dataset
                    scenBest_bestScore = max(score_mean_i(data_i,:));
                    scenBest_bestScoreInd = bsxfun(@eq, scenBest_bestScore, score_mean_i(data_i,:));
                    TopPRAconfigs_best{data_i,consFun_i} = scenBest_bestScoreInd;
                    SCORES_best_mean(data_i,consFun_i) = scenBest_bestScore;
                    % If there are multiple max scores, choose min std
                    % among them
                    SCORES_best_std(data_i,consFun_i) = min(score_std_i(data_i,scenBest_bestScoreInd));
                    
                    % Scenario 'crossValid': cross-validation on datasets - leave one out
                    datasets_train = 1:datasets_num;
                    datasets_train(datasets_train==data_i) = []; % remove data_i dataset
                    % average over train datasets
                    scenCrossValid_train = mean(score_mean_i(datasets_train,:),1);                    
                    % Find best PRAr on average for train datasets
                    [scenCrossValid_bestScore,scenCrossValid_i] = max(scenCrossValid_train,[],2);
                    scenCrossValid_bestScoreInd = bsxfun(@eq, scenCrossValid_bestScore, scenCrossValid_train);
                    TopPRAconfigs_crossValid{data_i,consFun_i} = scenCrossValid_bestScoreInd;
                    SCORES_crossValid_mean(data_i,consFun_i) = score_mean_i(data_i,scenCrossValid_i);
                    % If there are multiple max scores, choose min std among them
                    SCORES_crossValid_std(data_i,consFun_i) = min(score_std_i(data_i,scenCrossValid_bestScoreInd));
                end
                
            else
                % Conventional cons. fun. without PRA
                % Copy mean scores to all scenarios
                SCORES_average_mean(:,consFun_i) = score_mean_i;
                SCORES_best_mean(:,consFun_i) = score_mean_i;
                SCORES_crossValid_mean(:,consFun_i) = score_mean_i;
                SCORES_average_std(:,consFun_i) = score_std_i;
                SCORES_best_std(:,consFun_i) = score_std_i;
                SCORES_crossValid_std(:,consFun_i) = score_std_i;
            end
            
        end
        SCORES.(datasetCollection).(eCVI).all.mean = SCORES_all_mean;
        SCORES.(datasetCollection).(eCVI).all.std = SCORES_all_std;
        SCORES.(datasetCollection).(eCVI).average.mean = SCORES_average_mean;
        SCORES.(datasetCollection).(eCVI).average.std = SCORES_average_std;
        SCORES.(datasetCollection).(eCVI).average_topPRAconfigs = TopPRAconfigs_average;
        SCORES.(datasetCollection).(eCVI).best.mean = SCORES_best_mean;
        SCORES.(datasetCollection).(eCVI).best.std = SCORES_best_std;
        SCORES.(datasetCollection).(eCVI).best_topPRAconfigs = TopPRAconfigs_best;
        SCORES.(datasetCollection).(eCVI).crossValid.mean = SCORES_crossValid_mean;
        SCORES.(datasetCollection).(eCVI).crossValid.std = SCORES_crossValid_std;
        SCORES.(datasetCollection).(eCVI).crossValid_topPRAconfigs = TopPRAconfigs_crossValid;
        
    end
end

save([CONFIG.path.presentation,filesep,'SCORES.mat'],'SCORES');
fprintf('[OK]\n');
