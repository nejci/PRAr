function step5_runPyBayesAnalysis()
% Run Python script that compares consensus functions

fprintf('Running statistical analysis using Bayesian approach ... ');

% If 1, only Latex tables will be generated from already computed results. 
% Otherwise, Bayesian analysis will be rerun.
makeTablesOnly = 1;

% If makeTablesOnly == 0, numWorkers jobs are executed to complete the
% comparison of algorithms. Set this to 
numWorkers = 2;

pyScriptPath = [pwd,filesep,'BayesianAnalysis.py'];
commandStr = ['python "',pyScriptPath,'" ',num2str(makeTablesOnly),' ', num2str(numWorkers)];
[status, commandOut] = system(commandStr);
%fprintf(1,'Done. Status is %d.\nOutput:\n%s\n',status,commandOut);
fprintf('[OK]\n');