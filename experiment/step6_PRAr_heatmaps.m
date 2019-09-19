function step6_PRAr_heatmaps()
% Analyze PRAr configurations
% Heatmaps with MEDIAN score over datasets

fprintf('Producing heatmaps of PRAr configuration scores ... ');

% Figure properties
figureSize = [3.5 6.57];
fontSize = 6.5;
fontName = 'Arial';
formatString = '%.4f';
% Custom colormap
cmap = load('colormap_gray.mat');
cmap = cmap.cmap;

% Load configuration
CONFIG = load('config.mat');
CONFIG = CONFIG.CONFIG;

% Computed scores
SCORES = load([CONFIG.path.presentation,filesep,'SCORES.mat']);
SCORES = SCORES.SCORES;

% Select cons. functions to display in a heatmap.
consFunctions = {'EAC-SL-Wn' 'EAC-SL-Wr' 'STREHL-CSPA-Wn' 'STREHL-CSPA-Wr' 'DICLENS-Wn' 'DICLENS-Wr' };
mergeConsFunctions = [1,2; 3,4; 5,6]; % each row is a pair to merge
mergedConsName = {'EAC-W', 'CSPA-W', 'DICLENS-W'};
mergeConsFunctions_num = size(mergeConsFunctions,1);

% Datasets
DATA_INFO = load([CONFIG.path.datasets,filesep,'datasets_info.mat']);
DATA_INFO = DATA_INFO.DATA_INFO;
datasetCollections = fieldnames(DATA_INFO);
datasetCollections_num = length(datasetCollections);

% eCVI
CVI_ext = CONFIG.CVI.external;
CVI_ext_num = length(CVI_ext);

% Save folder
path_saveResults = [CONFIG.path.presentation,filesep,'PRAr-heatmaps'];
[~,~,~] = mkdir(path_saveResults);

% Prepare PRA configurations:
%   - merge PRA and PRAr
%   - join unification and aggregation functions
%   - rename algorithms
PRA_TABLE_MERGED = [...
    CONFIG.consFunctionsParams.PRA_TABLE;...
    CONFIG.consFunctionsParams.PRAr_TABLE];
PRA_TABLE_NEW = [strcat(renameAlgorithms(PRA_TABLE_MERGED(:,1)),{' - '},renameAlgorithms(strcat(PRA_TABLE_MERGED(:,4),PRA_TABLE_MERGED(:,5)))), PRA_TABLE_MERGED(:,2)];
pra_table_num = size(PRA_TABLE_NEW,1);
[unify_wight_u,~,unify_weight_ind] = unique(PRA_TABLE_NEW(:,1),'sorted');            
unify_weight_num = numel(unify_wight_u);
[reduce_u,~,reduce_ind] = unique(renameAlgorithms(PRA_TABLE_NEW(:,2)),'stable');
reduce_num = numel(reduce_u);
ind_mat = [unify_weight_ind, reduce_ind];

for dataColl_i = 1:datasetCollections_num
    datasetCollection = datasetCollections{dataColl_i};
    
    for eCVI_i = 1:CVI_ext_num
        eCVI = CVI_ext{eCVI_i};
        
        scores_all = SCORES.(datasetCollection).(eCVI).all;        
        scores_median = cell(1,mergeConsFunctions_num);
        
        for mI = 1:mergeConsFunctions_num
            ind1 = strcmpi(consFunctions{mergeConsFunctions(mI,1)}, CONFIG.consFunctions);
            ind2 = strcmpi(consFunctions{mergeConsFunctions(mI,2)}, CONFIG.consFunctions);
            SCORES_FULL = [scores_all{ind1}, scores_all{ind2}];
            scores_median{mI} = median(SCORES_FULL,1)';
        end
                
        fig = figure('units','inches','position',[0 0 figureSize], 'PaperSize',figureSize);
        numCols = 1;
        
        for consMethod_i = 1:mergeConsFunctions_num
            consMethod = mergedConsName{consMethod_i};
            
            scores_median_i = scores_median{consMethod_i};            
            heatmap_values = zeros(unify_weight_num,reduce_num);
            for m=1:pra_table_num
                heatmap_values(ind_mat(m,1),ind_mat(m,2)) = scores_median_i(m);
            end
            
            % Heatmap for scenario 'average' (best config on average over all
            % datasets)
            subplot(mergeConsFunctions_num,numCols,consMethod_i-numCols+1);
            hmap = heatmap(reduce_u,unify_wight_u,heatmap_values);
            hmap.Title = [datasetCollection,' - ',eCVI,' - ',renameAlgorithms(consMethod)];
            hmap.XLabel = '\Pi';
            hmap.YLabel = '';%'\Gamma - \Omega';
            %hmap.CellLabelColor = 'auto';
            hmap.CellLabelColor = [0 0 0];  
            hmap.Colormap = cmap;
            hmap.CellLabelFormat = formatString;
            hmap.FontSize = fontSize;
            hmap.FontName = fontName;
            
        end
        
        saveas(fig,[path_saveResults,filesep,datasetCollection,'-',eCVI,'-median.pdf']);
        close(fig);
        
    end
    
end
fprintf('[OK]\n');