% CONSENSUS
%
%
%

% Parallel version - parfor on loop over PRA configurations
numWorkers = 2;
% Use parallel loop - create new pool if there is none or with different
% number of workers
currentPool = gcp('nocreate');
if isempty(currentPool) || currentPool.NumWorkers ~= numWorkers
    delete(currentPool);
    parpool(numWorkers);
end

% Load configuration
CONFIG = load('config.mat');
CONFIG = CONFIG.CONFIG;

% Datasets
DATA = load([CONFIG.path.datasets,filesep,'datasets_data.mat']);
DATA = DATA.DATA;
DATA_INFO = load([CONFIG.path.datasets,filesep,'datasets_info.mat']);
DATA_INFO = DATA_INFO.DATA_INFO;
datasetCollections = fieldnames(DATA_INFO);
datasetCollections_num = length(datasetCollections);

% Consensus functions
consFunctions = CONFIG.consFunctions;
consFunctions_num = length(consFunctions);

% Validate consensus partitions with the following external indices
CVI_ext = CONFIG.CVI.external;

M = CONFIG.ensembleSize;
R = CONFIG.numRepetitions;



timeID = tic();

% LOOP over consensus functions
for consFun_i = 1:consFunctions_num
    consFunction = consFunctions{consFun_i};
    consFun = consFunction;
    
    timeIDCons = tic();
    
    
    isPRAEnabled = 0;
    C = 1; % number of PRA configurations
    % Consider PRAr configuration for weighted cons. functions
    if strcmpi(consFunction,'JWEAC-SL') || ...
            strcmpi(consFunction(1:end-1),'EAC-SL-W') || ...
            strcmpi(consFunction(1:end-1),'DICLENS-W') ||...
            (strcmpi(consFunction(1:7),'STREHL-') && strcmpi(consFunction((end-2):(end-1)),'-W'))
        
        isPRAEnabled = 1;
        
        % Resolve names 
        % EAC-SL-W -> WEAC-SL 
        % JWEAC is special case of WEAC
        if strcmpi(consFunction,'JWEAC-SL')
            consFun = 'WEAC-SL';
            PRA_config_struct = CONFIG.consFunctionsParams.JWEAC;
        else
            % Load appropriate PRA configs
            if consFunction(end) == 'r'
                PRA_config_struct = CONFIG.consFunctionsParams.PRAr;
            elseif consFunction(end) == 'n'
                PRA_config_struct = CONFIG.consFunctionsParams.PRA;
            else
                error('Wrong consensus function.');
            end
            
            % Adapt names for a function call (Pepelka package)
            if strcmpi(consFunction(1:end-1),'EAC-SL-W')
                consFun = 'WEAC-SL';
            elseif strcmpi(consFunction(1:7),'STREHL-')
                consFun = consFunction(1:end-1);
            elseif strcmpi(consFunction(1:end-1),'DICLENS-W')
                consFun = 'DICLENS-W';
            else
                error('Wrong consensus function.');
            end
        end
        
        PRA_CONFIG = preparePRArConfig(PRA_config_struct);
        C = size(PRA_CONFIG,1);
    end
    
    % LOOP over data collections
    for dataColl_i = 1:datasetCollections_num
        datasetCollection = datasetCollections{dataColl_i};
        datasetNames = fieldnames(DATA_INFO.(datasetCollection));
        datasets_num = length(datasetNames);
        
        for data_i = 1:datasets_num
            datasetName = datasetNames{data_i};
            
            data_info = DATA_INFO.(datasetCollection).(datasetName);
            target = data_info.target;
            K = data_info.Ktrue;
            N = data_info.numSamples;         
            
            % Set dataset-specific parameters for a consensus function
            CONS_params = pplk_setParamsDefault();
            CONS_params.LCE_dc = CONFIG.consFunctionsParams.LCE_dc; % decay factor
            CONS_params.PAC_dim = data_info.numDimensions; % dimensionality of the data
            
            % Compute pairwise data distances for WEA
            if strcmpi(consFunction(1:4),'WEA-')
                dataDist = 'euclidean';
                dataMode = 'dist';
                data = DATA.(datasetCollection).(datasetName).data;
                distMatrix = squareform(pdist(data,dataDist));
                CONS_params.WEA_dataDist = dataDist;
                CONS_params.WEA_dataMode = dataMode;
                CONS_params.WEA_data = distMatrix;
                CONS_params.WEA_normalize = 1;
            end
                        
            
            % Load a file with the ensemble members            
            ENS_path = [...
                CONFIG.path.ensemble,filesep,...
                datasetCollection,filesep,'ENS_',datasetName,'.mat'];
            ENS = load(ENS_path);
            ENS = ENS.ENS;
            
            % If PRAr, load precomputed internal CVIs into CVImat
            if isPRAEnabled
                CVI_path = [...
                    CONFIG.path.CVI,filesep,...
                    datasetCollection,filesep,'CVI_',datasetName,'.mat'];
                CVI = load(CVI_path);
                CVI = CVI.CVI;                
                CVI_int = CVI.info.CVI_internal;
                
                if numel(PRA_config_struct.WEAC_CVI)==1 && ...
                        strcmpi(PRA_config_struct.WEAC_CVI{1},'ALL')
                    CVI_selected = true(1,length(CVI_int));
                    WEAC_CVI = CVI_int;
                else
                    CVI_selected = ismember(CVI_int,PRA_config_struct.WEAC_CVI);
                    WEAC_CVI = CVI_int(CVI_selected);
                end
                CVImat = CVI.internal(:,CVI_selected);
                
            end
            
            % Prepare space for results
            % Consensus partitions
            CP = zeros(N,R,C);
            % Validation scores
            validationScores = zeros(length(CVI_ext),R,C);
            % Time measurement
            time = zeros(C,R);
            
            % Loop over repetitions
            parfor r_i = 1:R
                CONS_params_i = CONS_params;
                % Select M partitions from the pool
                startInd = (r_i-1)*M+1;
                endInd = r_i*M;
                labelsENS = ENS(:,startInd:endInd);
                
                % Select CVI values from CVImat
                if isPRAEnabled
                    CVImat_sel = CVImat(startInd:endInd,:);
                    CONS_params_i.WEAC_CVImat = CVImat_sel;
                end
                
                
                
                % Loop over PRAr configurations (C=1 if PRAr is not on)
                for c_i = 1:C
                    
                    % Prepare PRAr parameters
                    if isPRAEnabled
                        conf_vec = PRA_CONFIG(c_i,:);                        
                        CONS_params_i.WEAC_CVI = WEAC_CVI;
                        CONS_params_i.WEAC_unifyMeth = conf_vec{1};
                        CONS_params_i.WEAC_reduceMeth = conf_vec{2};
                        CONS_params_i.WEAC_reduceDim = conf_vec{3};
                        CONS_params_i.WEAC_weightMeth = conf_vec{4};
                        CONS_params_i.WEAC_weightMode = conf_vec{5};
                    end
                    
                    warning('off');
                    % Compute consensus partition                    
                    ticID = tic();
                    CP(:,r_i,c_i) = pplk_consEns(labelsENS, K, consFun, CONS_params_i);
                    time(c_i,r_i) = toc(ticID);
                    
                    % Validate consensus partition with external indices
                    [~,validationScores(:,r_i,c_i)] = ...
                        pplk_validExt(target,CP(:,r_i,c_i),CVI_ext);
                    
                    warning('on');
                end
                
                
                
            end
            
            fprintf(1,'-- DONE: %.3f s (avg) | %.3f s (sum) | %s | %s | %s\n', ...
                mean(time(:)),sum(time(:)), consFunction, datasetCollection, datasetName);
            
            % Save results
            CONS = [];
            CONS.CP = CP;
            CONS.validationScores = validationScores;
            CONS.time = time;
                        
            % Create folder to store results
            results_folder = [CONFIG.path.consensus,filesep,...
                datasetCollection,filesep,consFunction];
            [~,~,~] = mkdir(results_folder);
            results_path = [results_folder,filesep,'CP_',datasetName,'.mat'];
            save(results_path, 'CONS');
            
        end
    end
    elapsedTimeCons = toc(timeIDCons);
    fprintf(1,'%s done -------- time: %f h\n',consFunction, elapsedTimeCons/3600);
end
elapsedTime = toc(timeID);
fprintf(1,'ALL cons. fun. done --------- total time: %f h\n',elapsedTime/3600);

