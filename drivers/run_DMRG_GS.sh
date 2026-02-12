#!/bin/bash
mg=$1
l=$2
x=$3
N=$4
d=$5
dir=$g


if [ "${d}" = "inf" ]; then 
        julia ~/repositories/schwingermodeltn/src/runSchwingerDMRG_noGaugeField.jl ${N} ${x} ${mg} 35 400 ${l} 2 20 400 "$dir/DMRG" 1E-13 0 >> $dir/DMRG/outs/mg${mg}_l${l}_x${x}_N${N}_d${d}.out
else
        julia ~/repositories/schwingermodeltn/src/runSchwingerDMRG.jl ${N} ${d} ${x} ${mg} 100 20 400 ${l} 2 20 400 "$dir/DMRG" 1E-13 0 >> $dir/DMRG/outs/mg${mg}_l${l}_x${x}_N${N}_d${d}.out
fi
 
