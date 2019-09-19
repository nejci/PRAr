function renamed = renameAlgorithms(algorithms)
% rename algorithms
singleMode = 0;
if (iscell(algorithms) && numel(algorithms) == 1) || ischar(algorithms)
    singleMode = 1;
    algorithms = {algorithms};
end

str = {'SpecLS', 'STREHL-CSPA', 'STREHL-MCLA', 'STREHL-HGPA','EAC-SL','EAC_W','PAC-SL','WEA-SL','LCE-CTS-SL','DICLENS','STREHL_CSPA_W','DICLENS_W','JWEAC_SL','PWEAC_SL','STREHL_CSPA_W_none','STREHL_CSPA_W_red','DICLENS_W_none','DICLENS_W_red','PWEAC_SL_none','PWEAC_SL_red', 'minmax', 'prob', 'rank10', 'wMean2', 'wMin2', 'wVegaPons2CLK', 'wVegaPons2CBK', 'wRankAggreg2RRA','ProbPCA','SPEC','NONE'};
rep = {'Sp','CSPA', 'MCLA', 'HGPA','EAC','EAC-W','PAC','WEA','LCE','DICLENS','CSPA-W','DICLENS-W','JWEAC','EAC-W','CSPA-Wn','CSPA-Wr','DICLENS-Wn','DICLENS-Wr','EAC-Wn','EAC-Wr','max', 'prob', 'rank', 'mean', 'min', 'CLK', 'CBK', 'RRA','PPCA','SFS','none'};


for i = 1:numel(algorithms)
    ind = strcmpi(algorithms{i},str);
    if sum(ind) == 1
        algorithms{i} = rep{ind};
    end
end

if singleMode
    renamed = algorithms{1};
else
    renamed = algorithms;
end