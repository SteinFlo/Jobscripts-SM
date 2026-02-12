#!/bin/bash

TEscript="/data/fstein/drivers/run_QuenchTE.jl"
GSscript="/data/fstein/drivers/run_DMRG_GS.sh"

if [ "$#" -ne 16 ]; then
    echo "Number of parameters given: "$# ", needs 16." 
    echo "Usage:" 
    echo "makeQuenchSS.sh N d truncation x m/g m/g2 l0 l0_2  dt k1 kstep k2 order cutoff cores mem"
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
    mg2=$6
    l0=$7
    l0_2=$8
    dt=$9
    k1=${10}
    kstep=${11}
    k2=${12}
    order=${13}
    cutoff=${14}

    cores=${15}
    mem=${16}

    timestamp=$(date +%F_%T)

    out="/data/fstein/slurmscripts/Quench/Q-N${N}_d${dimsymb}_x${x}_mg${mg}-${mg2}_l0${l0}-${l0_2}_dt${dt}_k${k1}-${kstep}-${k2}_ord${order}_cut${cutoff}_${timestamp}.sh"



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"  >> $out 
    echo "#SBATCH --requeue"            >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 
    echo " " >> $out 

    echo 'scratch=/scr/$SLURM_JOB_ID'   >> $out
    echo 'mntpoint=$scratch/mnt'        >> $out
    echo 'mkdir -p $mntpoint'           >> $out
    echo " " >> $out 

    echo 'driverGS=$scratch/driverGS'   >> $out
    echo 'driverTE=$scratch/driverTE'   >> $out
    echo 'container=$scratch/container' >> $out
    echo " " >> $out 

    echo "cp $GSscript"  '$driverGS'    >> $out
    echo "cp $TEscript"  '$driverTE'    >> $out
    echo 'cp /data/fstein/builds/ITensor-julia-wo.sif $container' >> $out
    echo " " >> $out

    echo -n "singularity exec \\
             --fusemount \"container:sshfs godot3:/localdisk/.fstein" '$mntpoint'\" "\\
             --bind" '$scratch':'$scratch' "\\
            "'$container' '$driverGS' "$mg $l0 $x $N $dimsymb" '$mntpoint' >> $out
    for k in $(seq $k1 $kstep $k2); do
        echo " && \\" >> $out 
        echo -n "singularity exec \\
                 --fusemount \"container:sshfs godot3:/localdisk/.fstein" '$mntpoint'\" "\\
                 --bind" '$scratch':'$scratch' "\\
                "'$container' '$driverTE' "$N $d $truncation $x  $mg $mg2 $l0 $l0_2 $dt $k $order $cutoff" '$mntpoint' >> $out
    done

    echo 'rm -rf $scratch' >> $out
    chmod +x $out
fi

