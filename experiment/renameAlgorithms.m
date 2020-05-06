function renamed = renameAlgorithms(algorithms)
% rename algorithms
singleMode = 0;
if (iscell(algorithms) && numel(algorithms) == 1) || ischar(algorithms)
    singleMode = 1;
    algorithms = {algorithms};
end

dict = {
    'SpecLS', 'Sp'
    'STREHL-CSPA', 'CSPA'
    'STREHL-MCLA', 'MCLA'
    'STREHL-HGPA', 'HGPA'
    'STREHL_CSPA_W', 'CSPA-W'
    'STREHL-CSPA-W', 'CSPA-W'
    'STREHL-CSPA-Wn', 'CSPA-W'
    'STREHL_CSPA_W_none', 'CSPA-W'
    'STREHL-CSPA-Wr', 'CSPA-Wr'
    'STREHL_CSPA_W_red', 'CSPA-Wr'
    'STREHL_MCLA_W', 'MCLA-W'
    'STREHL-MCLA-W', 'MCLA-W'
    'STREHL_MCLA_W_none', 'MCLA-W'
    'STREHL_MCLA_W_red', 'MCLA-Wr'
    'STREHL_HGPA_W', 'HGPA-W'
    'STREHL-HGPA-W', 'HGPA-W'
    'STREHL_HGPA_W_none', 'HGPA-W'
    'STREHL_HGPA_W_red', 'HGPA-Wr'
    'EAC-SL', 'EAC'
    'EAC_W', 'EAC-W'
    'EAC-SL-Wn', 'EAC-W'
    'EAC-SL-Wr', 'EAC-Wr'
    'PWEAC_SL', 'EAC-W'
    'PWEAC_SL_none', 'EAC-Wn'
    'PWEAC_SL_red', 'EAC-Wr'
    'JWEAC_SL', 'JWEAC'
    'JWEAC-SL', 'JWEAC'
    'PAC-SL', 'PAC'
    'WEA-SL', 'WEA'
    'LCE-CTS-SL', 'LCE'
    'DICLENS', 'DICLENS'
    'DICLENS_W', 'DICLENS-W'
    'DICLENS-Wn', 'DICLENS-W'
    'DICLENS-Wr', 'DICLENS-Wr'
    'DICLENS_W_none', 'DICLENS-Wn'
    'DICLENS_W_red', 'DICLENS-Wr'
    'minmax', 'max'
    'prob', 'sum'
    'rank10', 'rank'
    'wMean2', 'mean'
    'wMin2', 'min'
    'wVegaPons2CLK', 'CLK'
    'wVegaPons2CBK', 'CBK'
    'wRankAggreg2RRA', 'RRA'
    'ProbPCA', 'PPCA'
    'SPEC', 'SFS'
    'NONE', 'none'};


for i = 1:numel(algorithms)
    ind = strcmpi(algorithms{i},dict(:,1));
    if sum(ind) == 1
        algorithms{i} = dict{ind,2};
    end
end

if singleMode
    renamed = algorithms{1};
else
    renamed = algorithms;
end