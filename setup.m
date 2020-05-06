% =========================================================================
% Weighted Cluster Ensemble Based on 
% Partition Relevance Analysis With Reduction Step
% -------------------------------------------------------------------------
% Setup script
% -------------------------------------------------------------------------
% Writen by Nejc Ilc (nejc.ilc@fri.uni-lj.si)
% 2020-05-05
% =========================================================================

sep = repmat('-',1,72);
fprintf('%s\nPartition relevance analysis with reduction step\nSETUP\n%s\n\n',sep,sep);

% Run setup script that initializes toolbox for cluster ensembles - Pepelka
fprintf('Configuring Pepelka toolbox for cluster ensembles.\nYou will be prompted to take some decisions during the setup.\n');
oldDir = chdir('Pepelka');
setup();
chdir(oldDir);
fprintf('END of Pepelka setup.\n');

% Check for Python
fprintf('\n%s\nChecking Python.\n',sep);
[status, output] = system('python3 --version');
if status
    [status, output] = system('python --version');
end
if status
   error('Sorry, Python is missing or is not on the path: %s\n', output);
else
    tok = strsplit(output,' ');
    if strcmpi(tok{1},'Python')
        if tok{2}(1) ~= '3'
            error('Sorry, Python 3 is required.\n');
        end
    else
        error('Sorry, Python is missing or is not on the path.\n'); 
    end
end
% Install Python libraries
fprintf('Installing required Python libraries (from requirements.txt).\n');
system('pip install -r ./requirements.txt');

% Provide links for example and experiment
fprintf('\n%s\nAll done.\n',sep);
fprintf('To run an example of PRAr and Pepelka, move to "example" folder and run "demo_PRAr.m".\n');
fprintf('To run the full experiment, move to "experiment" folder and run "runExperiment.m".\n');

