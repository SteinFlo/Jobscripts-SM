#!/bin/bash

for dim in 5 10 20 
do
    for d in 3 5
    do
        for mg in 0  0.2  0.4  0.6  0.8    1.2  1.6 
        do
            for l in  -0.5 -0.25 0.0 0.25 0.5
            do
                 ./makeMij_k.sh 20 $d period 1   $mg $l 0.05 "[4,5,6]" 0.25 0 1 24 1 1e-14 5 20000 $dim
                 ./makeMij_k.sh 16 $d period 0.5 $mg $l 0.05 "[4,5,6]" 0.25 0 1 24 1 1e-14 5 20000 $dim
                 #./makeMij.sh 20 $d period x m/g l0 dt0 ks timestep begin step end order cutoff cores mem maxDim

            done
        done
    done
done
