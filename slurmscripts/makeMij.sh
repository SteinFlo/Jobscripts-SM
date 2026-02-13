#!/bin/bash

Mijscript="/data/fstein/drivers/run_Mij.jl"

if [ "$#" -ne 16 ]; then
    echo "Number of parameters given: "$# ", needs 14." 
    echo "Usage:" 
    echo "makeMij.sh N d truncation x m/g l0 dt0 dts timestep begin step end order cutoff cores mem"
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

    dt0=$7
    dts=$8
    timestep=$9
    
    begin=${10}
    step=${11}
    end=${12}

    order=${13}
    cutoff=${14}

    cores=${15}
    mem=${16}

    timestamp=$(date +%F_%T)

    dtstr="${dts// /}"

    out="/data/fstein/slurmscripts/Mij/Mij-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_dt${dt0}_${dtstr}_it${begin}-${step}-${end}_ord${order}_cut${cutoff}_${timestamp}.sh"
    echo $out

    numk=$(echo $dts | awk -F, '{print NF}')
    numpert=$(python3 -c "print($numk**2  + $numk)")
    minind=$(python3 -c "print($numpert*($begin-1)+1)")
    stepind=$(python3 -c "print($numpert*($step-1))")
    maxind=$(python3 -c "print($numpert*($end-1)+1)")



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"   >> $out 
    echo "#SBATCH --requeue"   >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 
    echo "#SBATCH --array=${minind}-${maxind}:${stepind}"         >> $out 

    echo 'scratch=/scr/${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}'   >> $out
    echo 'mntpoint=$scratch/mnt'        >> $out
    echo 'mkdir -p $mntpoint'           >> $out
    echo " " >> $out

    echo 'driverMij=$scratch/driverMij' >> $out
    echo 'container=$scratch/container' >> $out
    echo " " >> $out

    echo "cp $Mijscript"  '$driverMij'  >> $out
    echo 'cp /data/fstein/builds/ITensor-julia-wo.sif $container' >> $out
    echo " " >> $out




    echo "singularity exec \\
                 --fusemount \"container:sshfs godot3:/localdisk/.fstein" '$mntpoint'\" "\\
                 --bind" '$scratch':'$scratch' "\\
                "'$container' '$driverMij' $N $d $truncation $x  $mg $l0 $dt0 \"$dts\" $timestep $order $cutoff '$mntpoint' '${SLURM_ARRAY_TASK_ID}' >> $out

    echo 'rm -rf $scratch' >> $out

    chmod +x $out
fi

