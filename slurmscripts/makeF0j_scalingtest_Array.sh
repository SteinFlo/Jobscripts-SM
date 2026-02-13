#!/bin/bash

Fijscript="/data/fstein/drivers/run_Fij_MPO.jl"

if [ "$#" -ne 14 ]; then
    echo "Number of parameters given: "$# ", needs 14." 
    echo "Usage:" 
    echo "makeFij_test.sh N d truncation x m/g l0 dt k1 kstep k2 order cutoff cores mem"
else
    N=$1
    d=$2
    truncation=$3
    trunc=${truncation:0:1}

    if [ "$trunc" = "b" ]; then
        dimsymb=${d}
    else
        dimsymb="${d}${trunc}"
    fi  


    x=$4
    mg=$5
    l0=$6
    dt=$7

    ki1=${8}
    kstep=${9}
    ki2=${10}

    order=${11}
    cutoff=${12}

    cores=${13}
    mem=${14}

    timestamp=$(date +%F_%T)

    out="/data/fstein/slurmscripts/Fij/Fij-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_dt${dt}_k${ki1}-${kstep}-${ki2}_ord${order}_cut${cutoff}_${timestamp}.sh"



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"   >> $out 
    echo "#SBATCH --requeue"   >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 
    echo "#SBATCH --array=${ki1}-${ki2}:${kstep}"         >> $out 

    echo 'scratch=/scr/${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}'   >> $out
    echo 'mntpoint=$scratch/mnt'        >> $out
    echo 'mkdir -p $mntpoint'           >> $out
    echo " " >> $out

    echo 'driverFij=$scratch/driverFij' >> $out
    echo 'container=$scratch/container' >> $out
    echo " " >> $out

    echo "cp $Fijscript"  '$driverFij'  >> $out
    echo 'cp /data/fstein/builds/ITensor-julia-wo.sif $container' >> $out
    echo " " >> $out



    echo 'k=${SLURM_ARRAY_TASK_ID}' >> $out

    echo 'k0=$(python3 -c "print(2*$k)")' >> $out 
    echo 't=$(python3 -c "print('$dt'*$k)")' >> $out

    #echo -n "$container" $Fijscript $N $d $truncation $x  $mg $l0 '$t' '$k0' '$k' $order $cutoff >> $out

    echo "singularity exec \\
                 --fusemount \"container:sshfs godot3:/localdisk/.fstein" '$mntpoint'\" "\\
                 --bind" '$scratch':'$scratch' "\\
                "'$container' '$driverFij' $N $d $truncation $x  $mg $l0 '$t' '$k0' '$k' $order $cutoff '$mntpoint' >> $out

    echo 'rm -rf $scratch' >> $out

    chmod +x $out
fi

