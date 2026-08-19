#!/bin/bash

for dt in 0.05 0.1 0.2 0.5 1.0
do
    for d in 3 5
    do
        for mg in 0 0.1 0.2 0.3 0.4 0.5 0.6  0.8  1.0  1.2 1.4  1.6 
        do
            for l in  0.1  0.2  0.3 0.4 0.5
            do
                 ./makeFermiStrSlurm_loop.sh 20 $d period 1 $mg  $l 6 13 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 20 $d period 1 $mg -$l 6 13 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 20 $d period 1 $mg  $l 8 12 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 20 $d period 1 $mg -$l 8 12 $dt 0.0 $dt 5 1 1e-12 5 20000

                 ./makeFermiStrSlurm_loop.sh 16 $d period 0.5 $mg  $l 4 11 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 16 $d period 0.5 $mg -$l 4 11 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 16 $d period 0.5 $mg  $l 5 10 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 16 $d period 0.5 $mg -$l 5 10 $dt 0.0 $dt 5 1 1e-12 5 20000
            done
                 ./makeFermiStrSlurm_loop.sh 20 $d period 1 $mg  0  6 13 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 20 $d period 1 $mg  0  8 12 $dt 0.0 $dt 5 1 1e-12 5 20000

                 ./makeFermiStrSlurm_loop.sh 16 $d period 0.5 $mg  0  4 11 $dt 0.0 $dt 5 1 1e-12 5 20000
                 ./makeFermiStrSlurm_loop.sh 16 $d period 0.5 $mg  0  5 10 $dt 0.0 $dt 5 1 1e-12 5 20000
        done
    done
done

