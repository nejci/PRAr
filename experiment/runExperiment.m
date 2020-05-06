% =========================================================================
% Weighted Cluster Ensemble Based on 
% Partition Relevance Analysis With Reduction Step
% -------------------------------------------------------------------------
% The experiment
% -------------------------------------------------------------------------
% Writen by Nejc Ilc (nejc.ilc@fri.uni-lj.si)
% 2020-05-01
% =========================================================================

% Results are already computed and stored in the following folders:
%     '1-ensemble': cluster ensembles
%     '2-cluster-validation': ensemble members validated by CVIs
%     '3-consensus-functions': consensus partitions
%     '4-presentation': functions for results presentation (reproduction of
%     tables and figures in the paper)
%
% This code reproduce figures and tables in the paper. So, it only affects 
% the '4-presentation' folder.
% However, you can re-run computation of consensus partitions by invoking
% consensusFunction.m or consensusFunction_parfor.m (a parallel version).

% To reproduce published results, follow these steps:
% 1. Compile experiment configuration and save it to config.mat
step1_config();

% 2. Gather results from consensus functions output. Consider different
% evaluation protocols.
step2_gatherWithProtocols();

% 3. Export performance scores into text files, which are the input for
% Bayesian analysis in Python.
step3_exportScores();

% 4. Run Python script that visualizes performance of consensus functions
% using violin plots.
step4_runPyPlotViolins();

% 5. Run Python script for comparing consensus function using Bayesian
% approach. By default, this script only generates Latex tables from
% precomputed results. If you want to re-run the Bayesian analysis, set the
% variable 'makeTablesOnly' in the following function to 0.
step5_runPyBayesAnalysis();

% 6. Display heatmap of scores for each PRAr configuration.
step6_PRAr_heatmaps();

% 7. Create Latex tables with AMI scores for each dataset
step7_createTables();
