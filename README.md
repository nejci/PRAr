# PRAr
_Partition Relevance Analysis with the reduction step_

This repository contains supporting material for the paper 
*Weighted Cluster Ensemble Based on Partition Relevance Analysis With Reduction Step*, Nejc Ilc (in review).

## Requirements

- [MATLAB](https://www.mathworks.com/products/matlab.html)
- [Python3](https://www.python.org/downloads/)

Code was tested with *MATLAB R2019a* and *Python 3.7.4* on *Windows 10*. 
Please, give us feedback if you experience any troubles on other configurations.

## Installation

- Download and unzip into a folder on your computer.
- Open the folder in MATLAB.
- Run `setup.m`.

After successful setup, consider the following:
- `example/demo_PRAr.m`: a demo script showing the main functionalities of PRAr in the context of weighted cluster ensemble;
- `experiment/runExperiment.m`: script for the reproduction of the results published in the paper.


## Pepelka toolbox

The Pepelka toolbox is required to run an example on PRAr and full experiment. 
Pepelka (means *Cinderella* in the Slovene language) is a MATLAB toolbox for data clustering and visualization.
It provides functions for: 
- data loading and preprocessing, 
- finding clusters using single-clustering and ensemble methods,
- cluster internal and external validation,
- visualization of clustering results.

Pepelka includes a lot of artificial and real datasets. 

A pre-release of Pepelka is included here.
