#!/bin/bash

for mg in 0 0.1 0.2 0.4 0.8 1.6
do
    for l in 0.0 0.1 0.2 0.3 0.4 0.5
    do
         ./makeFermiStrSlurm_loop.sh 50 5 period 4 $mg $l 18 33 0.05 0.0 0.05 10 2 1e-11 20 100000
         ./makeFermiStrSlurm_loop.sh 50 5 period 4 $mg $l 19 34 0.05 0.0 0.05 10 2 1e-11 20 100000
    done
done

