function step7_createTables()
% Create tables with scores mean and std.
% Distinguish between PRA and non-PRA consensus functions (to save space)
% For non-PRA functions create a table for each combination of data
% collection and eCVI (REAL-AMI, GENE-AMI, ...).
% For PRA functions create a table for each combination of data
% collection, eCVI, and scenario (REAL-AMI-best, REAL-AMI-CV, GENE-AMI-best, GENE-AMI-CV, ...).


fprintf('Creating latex tables with scores ... ');

saveFolder = 'tables-latex';
savePrefix = 'table';

cons_nonPRA = {'DICLENS','LCE-CTS-SL','EAC-SL','PAC-SL','STREHL-CSPA','STREHL-HGPA','STREHL-MCLA','WEA-SL','JWEAC-SL'};
cons_PRA = {'EAC-SL-Wn','STREHL-CSPA-Wn','DICLENS-Wn','EAC-SL-Wr','STREHL-CSPA-Wr','DICLENS-Wr'};
num_cons_nonPRA = length(cons_nonPRA);
num_cons_PRA = length(cons_PRA);
cons_nonPRA_rn = renameAlgorithms(cons_nonPRA);
cons_PRA_rn = renameAlgorithms(cons_PRA);

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
% Indices of (non)PRA cons. functions.
[~,cons_nonPRA_ind] = ismember(cons_nonPRA, consFunctions);
[~,cons_PRA_ind] = ismember(cons_PRA, consFunctions);

% External validity indices
CVI_ext = CONFIG.CVI.external;
CVI_ext_num = length(CVI_ext);


path_saveResults = [CONFIG.path.presentation,filesep,saveFolder];
[~,~,~] = mkdir(path_saveResults);

%--------------------------------------------------------------------------
% Table head/end

table_head_nonPRA = {
    '\begin{table*}'
    '    \centering'
    '    \caption{TODO_CAPTION}'
    '    \label{tab:TODO_LABEL}'
    ['    \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l ',...
    repmat(' S[table-format=-1.3]',1,num_cons_nonPRA),'}']
    '        \toprule'
    ['        dataset ', sprintf('& {%s} ', cons_nonPRA_rn{:}), '\\ \midrule']
    };
table_head_PRA = {
    '\begin{table*}'
    '    \centering'
	'    \renewcommand{\pm}{\mathbin{\mbox{\unboldmath$\mathchar"2206$}}}'
    '    \caption{TODO_CAPTION}'
    '    \label{tab:TODO_LABEL}'
    ['    \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l ',...
    repmat(' S[table-format=-1.3(1)]',1,num_cons_PRA),'}']
    '        \toprule'
    ['        dataset ', sprintf('& {%s} ', cons_PRA_rn{:}), '\\ \midrule']
    };
table_end = {
    '    \end{tabular*}'
    '\end{table*}'
    };

%--------------------------------------------------------------------------
% Load scores
SCORES = load([CONFIG.path.presentation,filesep,'SCORES.mat']);
SCORES = SCORES.SCORES;

scenarios = CONFIG.presentation.scenarios;
scenarios_num = length(scenarios);


for dataColl_i = 1:datasetCollections_num
    datasetCollection = datasetCollections{dataColl_i};
    datasetNames = fieldnames(DATA_INFO.(datasetCollection));
    numDatasets = length(datasetNames);
    datasetNames = strrep(datasetNames,'voice_3','voice\_3');
    
    for eCVI_i = 1:CVI_ext_num
        eCVI = CVI_ext{eCVI_i};
        
        % Scenario
        for scenario_i = 1:scenarios_num
            scenario = scenarios{scenario_i};
            
            scenario_str = strrep(scenario,'crossValid','cross-validated');
            
            scores_mean = SCORES.(datasetCollection).(eCVI).(scenario).mean;
            scores_std = SCORES.(datasetCollection).(eCVI).(scenario).std;
            
            % Only once - create table for nonPRA cons. fun.
            if scenario_i == 1
                fileOutSuffix = ['-',datasetCollection,'-',eCVI,'-nonPRA'];                
                % Print to file
                fname = [savePrefix,fileOutSuffix,'.tex'];
                fid = fopen([path_saveResults,filesep,fname],'w');
                
                caption_str = sprintf('Mean and standard deviation of %s scores on %s datasets averaged over %d runs for consensus functions that do not utilize PRA(r). The best score for each dataset is highlighted in bold.', eCVI, datasetCollection, CONFIG.numRepetitions);
                table_head = strrep(...
                    table_head_nonPRA,'TODO_CAPTION',caption_str);
                table_head = strrep(table_head,'TODO_LABEL',['res-',datasetCollection,'-',eCVI]);
                fprintf(fid, '%s\n', table_head{:});
                
                for data_i = 1:numDatasets
                    fprintf(fid, '        \\multirow{2}{*}{\\textit{%s}}', datasetNames{data_i});
                    
                    % scores' mean
                    s = scores_mean(data_i,cons_nonPRA_ind);
                    s_max = max(s);
                    highlight = (s == s_max);
                    for cons_i = 1:num_cons_nonPRA                        
                        if highlight(cons_i)
                            fprintf(fid, ' & \\bfseries %.3f', s(cons_i));
                        else
                            fprintf(fid, ' & %.3f', s(cons_i));
                        end
                    end
                    fprintf(fid, '\\\\ \n        ');
                    
                    % std
                    for cons_i = 1:num_cons_nonPRA                        
                        if highlight(cons_i)
                            fprintf(fid, ' & \\bfseries \\pm %.3f', scores_std(data_i,cons_i)); 
                        else
                            fprintf(fid, ' & \\pm %.3f', scores_std(data_i,cons_i)); 
                        end
                    end
                    
                                       
                    if data_i == numDatasets
                        fprintf(fid, '\\\\ \\bottomrule\n');
                    else
                        fprintf(fid, '\\\\ \\midrule\n');
                    end
                end
                fprintf(fid, '%s\n', table_end{:});
                fclose(fid);
                
            end
            
            % PRA cons. fun.
            % numDatasets x numPRA table with elements 0.000 +/- 0.0000
            fileOutSuffix = ['-',datasetCollection,'-',eCVI,'-',scenario,'-PRA'];
            % Print to file
            fname = [savePrefix,fileOutSuffix,'.tex'];
            fid = fopen([path_saveResults,filesep,fname],'w');
            
            caption_str = sprintf('Mean and standard deviation of %s scores on %s datasets averaged over %d runs for consensus functions that utilize PRA(r) considering the \\textit{%s} evaluation protocol. The best score for each dataset is highlighted in bold.', eCVI, datasetCollection, CONFIG.numRepetitions, scenario_str);
            table_head = strrep(table_head_PRA, 'TODO_CAPTION', caption_str);
            table_head = strrep(table_head,'TODO_LABEL',['res-',datasetCollection,'-',eCVI,'-',scenario]);
            fprintf(fid, '%s\n', table_head{:});
            
            for data_i = 1:numDatasets
                fprintf(fid, '        \\textit{%s}', datasetNames{data_i});
                                
                % scores' mean
                s = scores_mean(data_i,cons_PRA_ind);
                sstd = scores_std(data_i,cons_PRA_ind);
                s_max = max(s);
                highlight = (s == s_max);
                for cons_i = 1:num_cons_PRA
                    if highlight(cons_i)
                        fprintf(fid, ' & \\bfseries %.3f \\pm %.3f', s(cons_i), sstd(cons_i));
                    else
                        fprintf(fid, ' & %.3f \\pm %.3f', s(cons_i), sstd(cons_i));
                    end
                    
                end
                fprintf(fid, '\\\\ \n');
            end
            fprintf(fid, '        \\bottomrule\n');
            fprintf(fid, '%s\n', table_end{:});
            fclose(fid);
        end 
    end    
end
fprintf('[OK]\n');