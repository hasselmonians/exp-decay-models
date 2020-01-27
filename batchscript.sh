#!/bin/bash -l

#$ -pe omp 16
#$ -o log
#$ -e err
#$ -P hasselmogrp
#$ -N exp-decay-models
#$ -l h_rt=24:00:00

module load matlab/2019b

matlab -nodisplay -singleCompThread -r "batchFunction('nSims', 100, 'nEpochs', 3); exit;"
