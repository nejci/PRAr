import os
from functools import lru_cache
import numpy as np

# Modified baycomp demo functions (baycomp/docs/code on https://github.com/janezd/ repository).

@lru_cache(1)
def _read_data(filename):
    data = []
    datasets = []
    classifiers = []
    basedir = os.path.split(__file__)[0]
    with open(os.path.join(basedir, filename)) as f:
        classifier = f.readline().strip()
        while True:  # loop over classifier
            if not classifier:
                break
            classifiers.append(classifier)
            data.append([])
            t_datasets = datasets and []
            while True:  # loop over data sets
                line = f.readline().strip()
                dataset, *scores = line.split() if line else ("",)
                if not scores:
                    # Check that order of data sets is same for all classifiers
                    assert datasets == t_datasets, 'Wrong order.'
                    classifier = dataset
                    break
                data[-1].append([float(x) for x in scores])
                t_datasets.append(dataset)
    return np.array(data), classifiers, datasets


def get_data(classifier=..., dataset=..., aggregate=False, filename='scores.txt'):
    def get_indices(names, pool):
        if names is ...:
            return np.arange(len(pool), dtype=int)
        if isinstance(names, str):
            return np.array([pool.index(names)])
        else:
            return np.array([pool.index(name) for name in names])

    data, classifiers, datasets = _read_data(filename)
    data = data[np.ix_(get_indices(classifier, classifiers),
                       get_indices(dataset, datasets))]
    if aggregate:
        data = np.mean(data, axis=2)
    data = data.squeeze()
    return data


def get_data_dict(aggregate=False):
    # only for fun
    data, classifiers, datasets = _read_data(filename)
    if aggregate:
        data = np.mean(data, axis=2)
    data = data.squeeze()
    data_dict = dict()
    for c_i, classifier in enumerate(classifiers):
        data_dict[classifier] = dict()
        for d_i, dataset in enumerate(datasets):
            data_dict[classifier][dataset] = data[c_i][d_i]
    return data_dict, classifiers, datasets


def get_classifiers(filename='scores.txt'):
    return _read_data(filename)[1]


def get_datasets(filename='scores.txt'):
    return _read_data(filename)[2]


# Helpers
def all_pairs(source):
    result = []
    for p1 in range(len(source)):
            for p2 in range(p1+1, len(source)):
                result.append([source[p1], source[p2]])
    return result


def rename_algorithms(s):
    rep_dict = {
        'STREHL-CSPA': 'CSPA',
        'STREHL-MCLA': 'MCLA',
        'STREHL-HGPA': 'HGPA',
        'EAC-SL': 'EAC',
        'PAC-SL': 'PAC',
        'WEA-SL': 'WEA',
        'LCE-CTS-SL': 'LCE',
        'DICLENS': 'DICLENS',
        'STREHL-CSPA-Wn': 'CSPA-W',
        'STREHL-CSPA-Wr': 'CSPA-Wr',
        'DICLENS-Wn': 'DICLENS-W',
        'DICLENS-Wr': 'DICLENS-Wr',
        'JWEAC-SL': 'JWEAC',
        'EAC-SL-Wn': 'EAC-W',
        'EAC-SL-Wr': 'EAC-Wr'}
    single_mode = False
    if isinstance(s, str):
        s = [s]
        single_mode = True
    sout = []
    for sitem in s:
        if sitem in rep_dict.keys():
            sout.append(rep_dict[sitem])
        else:
            sout.append(sitem)
    if single_mode:
        sout = sout[0]
    return sout
