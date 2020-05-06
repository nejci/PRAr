""" Display scores with violin plots """

import itertools
import os
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from data import *

__author__ = "Nejc Ilc"
__copyright__ = "Copyright 2020, Nejc Ilc"
__license__ = "GPL"
__version__ = "0.9"
__email__ = "nejc.ilc@gmail.com"
__status__ = "Experimental"


sns.set(
    context="paper",
    style='whitegrid',
    font_scale=0.75,
    font='Arial',
    rc={
        'axes.edgecolor': '.9',
        'axes.facecolor': 'white',
        'grid.color': '.9',
        'grid.linestyle': '-',
        'grid.linewidth': '1',
        'axes.spines.bottom': False})


COLOR_VIOLIN = (1, 1, 1, 1)
COLOR_DATAPOINTS = 'crimson'
FORMAT_IMG = 'pdf'
dpi = 300
figsize = (7.16, 3.5)
SAVE_FIG = 1

scoresFolder = '4-presentation/baycomp-import'
outputFolder = '4-presentation/violin-plots'

datasetCollectionList = ['GENE', 'REAL']
eCVIList = ['AMI']

BESTscn = 'best'
CVscn = 'crossValid'

BESTscn_appendStr = ''

# Make comparisons for all the pairs
consFunctions = [
    'STREHL-MCLA',
    'STREHL-HGPA',
    'STREHL-CSPA', 'STREHL-CSPA-Wr', 'STREHL-CSPA-Wn',
    'EAC-SL', 'JWEAC-SL', 'EAC-SL-Wn', 'EAC-SL-Wr',
    'PAC-SL', 'WEA-SL', 'LCE-CTS-SL',
    'DICLENS', 'DICLENS-Wn', 'DICLENS-Wr']

consFunctionsPRA = [
    'EAC-SL-Wn', 'EAC-SL-Wr',
    'STREHL-CSPA-Wn', 'STREHL-CSPA-Wr',
    'DICLENS-Wn', 'DICLENS-Wr']

# Create folder
if SAVE_FIG:
    try:
        os.makedirs(outputFolder)
    except FileExistsError:
        # directory already exists
        pass


a = [datasetCollectionList, eCVIList]
configList = list(itertools.product(*a))


for config in configList:

    (datasetCollection, eCVI) = config
    fname = scoresFolder + '/' + 'scores-' + datasetCollection + '-' + eCVI
    fnameBEST = fname + '-' + BESTscn + '.txt'
    fnameCV = fname + '-' + CVscn + '.txt'

    scoresFilenameID = datasetCollection+'-'+eCVI
    print('*'*50)
    print(scoresFilenameID)

    n = len(consFunctions)
    nPRA = len(consFunctionsPRA)

    # Get datasets
    datasets = get_datasets(filename=fnameBEST)
    d = len(datasets)
    # Get accuracies for consFunctions and
    # sort them according to the median accuracy over all datasets
    scoresCV = np.zeros(shape=(n, d))
    avgScoresCV = np.zeros(n)
    for i, consFunction in enumerate(consFunctions):
        scores_i = get_data(classifier=consFunction, filename=fnameCV)
        scoresCV[i, ...] = scores_i
        avgScoresCV[i] = np.median(scores_i)
    # Sort scores
    avgScoresSortedIndCV = avgScoresCV.argsort()
    avgScoresSortedCV = avgScoresCV[avgScoresSortedIndCV]
    scoresSortedCV = scoresCV[avgScoresSortedIndCV]
    scoresSortedCV_T = np.transpose(scoresSortedCV)
    # Order classifiers
    classifiersSortedCV = []
    consFunctions_rn = rename_algorithms(consFunctions)
    for idx in avgScoresSortedIndCV:
        classifiersSortedCV.append(consFunctions_rn[idx])

    # Append PRAr methods from BEST protocol
    scoresBEST = np.zeros(shape=(nPRA, d))
    avgScoresBEST = np.zeros(nPRA)
    for i, consFunction in enumerate(consFunctionsPRA):
        scores_i = get_data(classifier=consFunction, filename=fnameBEST)
        scoresBEST[i, ...] = scores_i
        avgScoresBEST[i] = np.median(scores_i)
    # Sort scores
    avgScoresSortedIndBEST = avgScoresBEST.argsort()
    avgScoresSortedBEST = avgScoresBEST[avgScoresSortedIndBEST]
    scoresSortedBEST = scoresBEST[avgScoresSortedIndBEST]
    scoresSortedBEST_T = np.transpose(scoresSortedBEST)
    # Order classifiers
    classifiersSortedBEST = []
    consFunctionsPRA_rn = rename_algorithms(consFunctionsPRA)
    # Add a string to BEST scen. algs.
    consFunctionsPRA_rn = [s + BESTscn_appendStr for s in consFunctionsPRA_rn]
    for idx in avgScoresSortedIndBEST:
        classifiersSortedBEST.append(consFunctionsPRA_rn[idx])

    scoresSortedT = np.concatenate((scoresSortedCV_T, scoresSortedBEST_T), axis=1)
    avgScoresSorted = np.concatenate((avgScoresSortedCV, avgScoresSortedBEST)) 
    classifiersSorted = classifiersSortedCV + classifiersSortedBEST

    fig = plt.figure(figsize=figsize, dpi=dpi)
    scoresPlot = scoresSortedT
    methodsPlot = classifiersSorted
    for i, score in enumerate(avgScoresSorted):
        print(methodsPlot[i]+':\t'+str(score))

    ax = sns.violinplot(
        data=scoresPlot,
        inner='quartile',
        cut=0,
        scale='area',
        linewidth=1,
        color=COLOR_VIOLIN)
    ax2 = sns.swarmplot(
        data=scoresPlot,
        size=3,
        color=COLOR_DATAPOINTS,
        alpha=1)
    plt.xticks(np.arange(n+nPRA), methodsPlot, rotation=30, ha='right')

    (ymin, ymax) = ax2.get_ylim()
    ymin = (np.min(np.min(scoresPlot)))-0.01
    ymax = (np.floor(np.max(np.max(scoresPlot))*10)+1)/10
    ax2.set_ylim([ymin, ymax])

    plt.xlabel('')
    plt.ylabel(eCVI)
    plt.title(datasetCollection+' datasets')
    plt.tight_layout()

    if SAVE_FIG:
        fig.savefig(outputFolder+'/'+scoresFilenameID+'-violinPlot.'+FORMAT_IMG)
        plt.close(fig)
