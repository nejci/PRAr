function PRA_CONFIG = preparePRArConfig(S)

% create table of configurations

WEAC_unifyMeth = S.WEAC_unifyMeth;
WEAC_reduceMeth = S.WEAC_reduceMeth;
WEAC_reduceDim = S.WEAC_reduceDim;
WEAC_weightMeth = S.WEAC_weightMeth;
WEAC_weightMode = S.WEAC_weightMode;

num_unifyMeth = length(WEAC_unifyMeth);
num_reduceMeth = length(WEAC_reduceMeth);
num_reduceDim = length(WEAC_reduceDim);
num_weightMeth = length(WEAC_weightMeth);

num_all_comb = num_unifyMeth * num_reduceMeth * num_reduceDim * num_weightMeth;

PRA_CONFIG = cell(num_all_comb,5);
tInd = 1;
for i1=1:num_unifyMeth
    for i2=1:num_reduceMeth
        skipReduceDim = 0;
        for i3=1:num_reduceDim
            reduceDim_el = WEAC_reduceDim(i3);
            % if reduceMeth == NONE, ignore reduceDim
            % and continue
            if strcmpi(WEAC_reduceMeth{i2},'NONE')
                reduceDim_el = {''};
                skipReduceDim = 1;
            end
            
            for i4=1:num_weightMeth
                PRA_CONFIG(tInd,:) = ...
                    [WEAC_unifyMeth(i1), ...
                    WEAC_reduceMeth(i2), ...
                    reduceDim_el, ...
                    WEAC_weightMeth(i4), ...
                    WEAC_weightMode(i4)];
                tInd = tInd + 1;
            end
            
            if skipReduceDim
                break;
            end
        end
    end
end

% if not all combinations are possible, delete emtpy ones
% ones
if tInd < (num_all_comb+1)
    PRA_CONFIG(tInd:end,:) = [];
end

% Apply filter - some weight methods need specific unify method
% Find all occurences of wVegaPons(2) and wRankAggreg(2) and apply
% appropriate unification
% wVegaPons
maskVega = strcmpi('wVegaPons',PRA_CONFIG(:,4)) | strcmpi('wVegaPons2',PRA_CONFIG(:,4));
maskVegaCBK = maskVega & strcmpi('CBK',PRA_CONFIG(:,5));
maskVegaCLK = maskVega & strcmpi('CLK',PRA_CONFIG(:,5));
% replace unification method with range or prob
PRA_CONFIG(maskVegaCBK,1) = repmat({'range'},1,sum(maskVegaCBK));
PRA_CONFIG(maskVegaCLK,1) = repmat({'prob'},1,sum(maskVegaCLK));

% wVegaPons
maskRRA = strcmpi('wRankAggreg',PRA_CONFIG(:,4)) | strcmpi('wRankAggreg2',PRA_CONFIG(:,4));
% replace unification method with rank10
PRA_CONFIG(maskRRA,1) = repmat({'rank10'},1,sum(maskRRA));

% remove duplicates
[~,idxU] = unique( cell2table(PRA_CONFIG),'rows','stable');
PRA_CONFIG = PRA_CONFIG(idxU,:);

