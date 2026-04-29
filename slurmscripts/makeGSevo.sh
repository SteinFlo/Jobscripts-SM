#!/bin/bash

TEscript="/data/fstein/drivers/run_GSevo.jl"
GSscript="/data/fstein/drivers/run_DMRG_GS.sh"

if [ "$#" -ne 14 ]; then
    echo "Number of parameters given: "$# ", needs 14." 
    echo "Usage:" 
    echo "makeFermiSrgSS.sh N d truncation x m/g l0  dt k1 kstep k2 order cutoff cores mem"
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
    k1=${8}
    kstep=${9}
    k2=${10}
    order=${11}
    cutoff=${12}

    cores=${13}
    mem=${14}

    timestamp=$(date +%F_%T)

    out="/data/fstein/slurmscripts/GSevo/GS-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_dt${dt}_k${k1}-${kstep}-${k2}_ord${order}_cut${cutoff}_${timestamp}.sh"



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"  >> $out 
    echo "#SBATCH --requeue"            >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 
    echo "#SBATCH -t 7-00:00"         >> $out 
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
                 --fusemount \"container:sshfs -o reconnect godot3:/localdisk/.fstein" '$mntpoint'\" "\\
                 --bind" '$scratch':'$scratch' "\\
                "'$container' '$driverTE' "$N $d $truncation $x  $mg $l0 $dt $k $order $cutoff" '$mntpoint' >> $out
    done
    
    echo " " >> $out
    echo " " >> $out
    echo 'rm -rf $scratch' >> $out
    chmod +x $out
fi

