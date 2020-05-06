""" Performs Bayesian analysis of consensus function scores """
import matplotlib.pyplot as plt
import numpy as np
import itertools
import os
import sys
import csv
import baycomp as bc
from data import *
from multiprocessing import Pool

__author__ = "Nejc Ilc"
__copyright__ = "Copyright 2020, Nejc Ilc"
__license__ = "GPL"
__version__ = "0.9"
__email__ = "nejc.ilc@gmail.com"
__status__ = "Experimental"

makeTablesOnly = 1  # If 1, only Latex tables will be generated. Otherwise, Bayesian analysis will be rerun.
numWorkers = 1  # Number of parallel jobs to compute Bayes comparison.

argc = len(sys.argv)
if argc == 2:
    makeTablesOnly = int(sys.argv[1])
if argc == 3:
    makeTablesOnly = int(sys.argv[1])
    numWorkers = int(sys.argv[2])
if argc > 3:
    print('Error: number of input arguments larger than 2.')
    print('BayesianAnalysis.py [makeTablesOnly] [numWorkers]')
    exit(2)

# print('Bayesian analysis (makeTablesOnly: {}, numWorkers: {})'.format(makeTablesOnly, numWorkers))

scoresFolder = '4-presentation/baycomp-import'
outputFolder = '4-presentation/baycomp-results'
outputFolderFigsPairs = 'figs-pairs'
saveFigsPairs = 0
FIG_WIDTH = 3.5  # 7.16
FIG_HEIGHT = 11.5
FIG_FORMAT = 'pdf'
DPI = 300
boldThres = 0.5

rope = 0
protocolList = ['best', 'crossValid']
datasetCollectionList = ['GENE', 'REAL']
eCVIList = ['AMI']

# Make comparisons for all the pairs
consFunctions = [
    'EAC-SL-Wr',
    'STREHL-CSPA-Wr',
    'DICLENS-Wr',
    'EAC-SL-Wn',
    'STREHL-CSPA-Wn',
    'DICLENS-Wn',
    'EAC-SL',
    'STREHL-CSPA',
    'DICLENS',
    'STREHL-HGPA',
    'JWEAC-SL',
    'LCE-CTS-SL',
    'STREHL-MCLA',
    'PAC-SL',
    'WEA-SL',
    ]

consFunctionsPivot = [
    'EAC-SL-Wr', 'STREHL-CSPA-Wr', 'DICLENS-Wr']
nPivots = len(consFunctionsPivot)


def compareClassifiers(config):
    print('\t'.join(map(str, config)))

    (protocol, datasetCollection, eCVI) = config

    scoresFilenameID = datasetCollection+'-'+eCVI+'-'+protocol
    fname = scoresFolder + '/' + 'scores-'+scoresFilenameID+'.txt'

    outputFolder_i = outputFolder+'/'+scoresFilenameID+'-rope='+str(rope)+'/'

    # Get accuracies for classifiers and sort them
    # according to the mean accuracy over all datasets
    # avgScores = []
    # for classifier in consFunctions:
    #     scores = get_data(classifier=classifier, filename=fname)
    #     avgScore = np.mean(scores)
    #     avgScores.append([classifier, avgScore])
    # avgScores.sort(key=lambda avgScores: avgScores[1], reverse=True)
    classifiers = consFunctions  # [x[0] for x in avgScores]

    try:
        if saveFigsPairs:
            os.makedirs(outputFolder_i+'/'+outputFolderFigsPairs)
        else:
            os.makedirs(outputFolder_i)
    except FileExistsError:
        # directory already exists
        pass

    fileProbs = open(outputFolder_i + '/probsList.txt', 'w')
    fileProbs.write(scoresFilenameID+'\n')
    fileProbs.write('rope: ' + str(rope)+'\n')
    fileProbs.write('alg1\talg2\tP(alg1)\tP(rope)\tP(alg2)\n')

    # LOOP - compare all the pairs of classifiers
    pairs = all_pairs(classifiers)
    n = len(classifiers)
    probMat = np.zeros(shape=(n, n))
    probMatRope = np.zeros(shape=(n, n))

    for pair in pairs:
        names = (pair[0], pair[1])

        scores_A = get_data(classifier=names[0], filename=fname)
        scores_B = get_data(classifier=names[1], filename=fname)

        if saveFigsPairs:
            probs, fig = bc.two_on_multiple(
                scores_A, scores_B,
                rope=rope, names=names, plot=saveFigsPairs)
            fig.savefig(
                outputFolder_i+'/'+outputFolderFigsPairs+'/' +
                names[0]+'-vs-'+names[1]+'.pdf')
            plt.close(fig)
        else:
            probs = bc.two_on_multiple(scores_A, scores_B, rope=rope,
                                       names=names, plot=saveFigsPairs)

        # Store into n X n matrix
        i = classifiers.index(names[0])
        j = classifiers.index(names[1])
        # 1st classifier is better than 2nd
        probMat[i, j] = probs[0]
        probMat[j, i] = probs[2]
        probMatRope[i, j] = probs[1]
        probMatRope[j, i] = probs[1]

        probsStr = ['{:.5f}'.format(x) for x in probs]
        outStr = '{0}\t{1}\t{2}\n'.format(
            names[0], names[1], '\t'.join(probsStr))
        print(outStr, end='')
        fileProbs.write(outStr)
    print('-'*100)
    fileProbs.close()

    # Print out the comparison and rope matrix
    fileProbsMat = open(outputFolder_i + '/probsMat.txt', 'w')
    fileProbsMatRope = open(outputFolder_i + '/probsMatRope.txt', 'w')
    header = '-\t'+'\t'.join(classifiers)+'\n'
    fileProbsMat.write(header)
    fileProbsMatRope.write(header)
    for row in range(n):
        fileProbsMat.write(classifiers[row]+'\t')
        fileProbsMatRope.write(classifiers[row]+'\t')
        for col in range(n):
            fileProbsMat.write('{:.5f}'.format(probMat[row, col])+'\t')
            fileProbsMatRope.write('{:.5f}'.format(probMatRope[row, col])+'\t')
        fileProbsMat.write('\n')
        fileProbsMatRope.write('\n')

    fileProbsMat.close()
    fileProbsMatRope.close()


def generateTables():
    # Locate results; loop over eCVIs and protocols
    for eCVI in eCVIList:
        for protocol in protocolList:
            resultsFileGENE = outputFolder+'/GENE-'+eCVI+'-'+protocol+'-rope='+str(rope)+'/probsMat.txt'
            resultsFileREAL = outputFolder+'/REAL-'+eCVI+'-'+protocol+'-rope='+str(rope)+'/probsMat.txt'

            probsGENE = []
            with open(resultsFileGENE) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter='\t')
                line_count = 0
                for row in csv_reader:
                    if line_count == 0:
                        headerGENE = row
                        line_count += 1
                    else:
                        if any(x in row[0] for x in consFunctionsPivot):
                            probsGENE.append(row)
                        line_count += 1

            probsREAL = []
            with open(resultsFileREAL) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter='\t')
                line_count = 0
                for row in csv_reader:
                    if line_count == 0:
                        headerREAL = row
                        line_count += 1
                    else:
                        if any(x in row[0] for x in consFunctionsPivot):
                            probsREAL.append(row)
                        line_count += 1
            assert headerGENE == headerREAL, 'Headers must be equal.'

            fileTable = open(outputFolder+'/table-'+eCVI+'-'+protocol+'.tex', 'w')
            fileTable.write('\\begin{table}\n')
            fileTable.write('\t\\centering\n')
            fileTable.write('\t\t\\caption{Probabilities that proposed methods with PRAr are better than others considering the \\emph{'+protocol+'} protocol. Probabilities larger than 0.5 (an arbitrary threshold) are given in bold for convenience.}\n')
            fileTable.write('\t\t\\label{tab:bayescomp:'+protocol+'}\n')
            fileTable.write('\t\t\\begin{tabular*}{1.0\\linewidth}{@{\\extracolsep{\\fill}} l '+'c c '*nPivots+'}\n')
            fileTable.write('\t\t\t\\toprule\n')

            # Make header of Latex table
            header1 = '\t\t\t{compared vs.}'
            for cF in consFunctionsPivot:
                header1 += ' & \\multicolumn{2}{c}{'+rename_algorithms(cF)+'}'
            header1 += '\\\\ \n\t\t\t\cmidrule(lr){2-3}\n\t\t\t\cmidrule(lr){4-5}\n\t\t\t\cmidrule(lr){6-7}\n'
            header2 = '\t\t\t '+'& \multicolumn{1}{c}{GENE} & \multicolumn{1}{c}{REAL} '*nPivots + '\\\\ \\midrule\n'
            fileTable.write(header1)
            fileTable.write(header2)

            # Make table body
            line_count = 0
            table = ['']*len(consFunctions)
            for cF in consFunctions:
                table[line_count] = rename_algorithms(cF)
                for pivot_i in range(nPivots):
                    if cF == probsGENE[pivot_i][0]:
                        table[line_count] += '& \\textbf{-} '*2
                    else:
                        valGENE = float(probsGENE[pivot_i][line_count+1])
                        valREAL = float(probsREAL[pivot_i][line_count+1])
                        if valGENE >= boldThres:
                            table[line_count] += ' & '+'\\textbf{'+'{:.3f}'.format(valGENE)+'}'
                        else:
                            table[line_count] += ' & '+'{:.3f}'.format(valGENE)
                        if valREAL >= boldThres:
                            table[line_count] += ' & '+'\\textbf{'+'{:.3f}'.format(valREAL)+'}'
                        else:
                            table[line_count] += ' & '+'{:.3f}'.format(valREAL)
                table[line_count] += '\\\\\n'
                # Write to file
                fileTable.write('\t\t\t'+table[line_count])
                line_count += 1
            fileTable.write('\t\t\t\\bottomrule\n')
            fileTable.write('\t\t\\end{tabular*}\n')
            fileTable.write('\\end{table}\n')
            fileTable.close()



if __name__ == '__main__':

    if not makeTablesOnly:
        a = [protocolList, datasetCollectionList, eCVIList]
        configList = list(itertools.product(*a))

        with Pool(numWorkers) as p:
            p.map(compareClassifiers, configList)

    # Generate Latex tables
    generateTables()
