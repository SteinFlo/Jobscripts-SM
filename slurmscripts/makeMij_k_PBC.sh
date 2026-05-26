#!/bin/bash

Mijscript="/data/fstein/drivers/run_Mij_k_PBC.jl"

if [ "$#" -ne 17 ]; then
    echo "Number of parameters given: "$# ", needs 17." 
    echo "Usage:" 
    echo "makeMij.sh N d truncation x m/g l0 dt0 ks timestep begin step end order cutoff cores mem maxDim"
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
    ks=$8
    timestep=$9
    
    begin=${10}
    step=${11}
    end=${12}

    order=${13}
    cutoff=${14}

    cores=${15}
    mem=${16}
    maxDim=${17}

    timestamp=$(date +%F_%T)

    kstr="${ks// /}"
    kstr="${kstr//\]/}"
    kstr="${kstr//\[/}"

    out="/data/fstein/slurmscripts/Mij_k_PBC/Mij_k-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_dt0${dt0}_k_${kstr}_step${timestep}_it${begin}-${step}-${end}_ord${order}_cut${cutoff}_MD${maxDim}_${timestamp}.sh"
    echo $out

    numk=$(echo $ks | awk -F, '{print NF}')
    numpert=$(python3 -c "print($numk**2  + $numk)")
    maxslurmind=$(python3 -c "print(int((($end-$begin)/$step+1)*$numpert))")

    #minind=$(python3 -c "print($numpert*($begin-1)+1)")
    #stepind=$(python3 -c "print($numpert*($step))")
    #maxind=$(python3 -c "print($numpert*($end-1)+1)")



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"   >> $out 
#    echo "#SBATCH -w gothmog"   >> $out 
    echo "#SBATCH --requeue"   >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 
    echo "#SBATCH -t 7-00:00"         >> $out 
    #echo "#SBATCH --array=${minind}-${maxind}:${stepind}"         >> $out 
    #echo "#SBATCH --array=${begin}-${end}:${step}"         >> $out 
    echo "#SBATCH --array=1-${maxslurmind}"         >> $out 

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

    echo 'tind=$(python3 -c "print('$begin + $step'*((${SLURM_ARRAY_TASK_ID}-1)//'$numpert'))")' >> $out
    echo 'kind=$(python3 -c "print((${SLURM_ARRAY_TASK_ID}-1)%'$numpert')")' >> $out
    #echo 'ind=$(python3 -c "print(' '(${SLURM_ARRAY_TASK_ID} -1)' "* $numpert + 1)\")" >> $out 
    echo 'ind=$(python3 -c "print(int($kind + ($tind-1)*'$numpert'))")' >> $out 

    echo 'sleep $SLURM_ARRAY_TASK_ID' >> $out


    echo "singularity exec \\
                 --fusemount \"container:sshfs -o reconnect godot2:/localdisk/.fstein" '$mntpoint'\" "\\
                 --bind" '$scratch':'$scratch' "\\
                "'$container' '$driverMij' $N $d $truncation $x  $mg $l0 $dt0 \"$ks\" $timestep $order $cutoff '$mntpoint' '${ind}' $maxDim >> $out

    echo 'rm -rf $scratch' >> $out

    chmod +x $out
fi

