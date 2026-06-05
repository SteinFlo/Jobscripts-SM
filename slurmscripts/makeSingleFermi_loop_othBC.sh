#!/bin/bash

TEscript="/data/fstein/drivers/run_SingleCharge_otherBC_loop.jl"
GSscript="/data/fstein/drivers/run_DMRG_GS.sh"

if [ "$#" -ne 15 ]; then
    echo "Number of parameters given: "$# ", needs 16." 
    echo "Usage:" 
    echo "makeFermiSrgSS.sh N d truncation x m/g l0 N1  dt t1 tstep t2 order cutoff cores mem"
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
    N1=$7
    dt=$8
    t1=${9}
    tstep=${10}
    t2=${11}
    order=${12}
    cutoff=${13}

    cores=${14}
    mem=${15}

    timestamp=$(date +%F_%T)

    out="/data/fstein/slurmscripts/singlefermi_othBC/SF_oBC-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_N1-${N1}_dt${dt}_t${t1}-${tstep}-${t2}_ord${order}_cut${cutoff}_${timestamp}.sh"



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

    echo "echo $out" >> $out

    echo -n "singularity exec \\
             --fusemount \"container:sshfs godot2:/localdisk/.fstein" '$mntpoint'\" "\\
             --bind" '$scratch':'$scratch' "\\
            "'$container' '$driverGS' "$mg $l0 $x $N $dimsymb" '$mntpoint' >> $out
    echo " && \\" >> $out 
    echo -n "singularity exec \\
             --fusemount \"container:sshfs -o reconnect godot2:/localdisk/.fstein" '$mntpoint'\" "\\
             --bind" '$scratch':'$scratch' "\\
            "'$container' '$driverTE' "$N $d $truncation $x  $mg $l0 $N1  $dt $t1 $tstep $t2 $order $cutoff" '$mntpoint' >> $out

    echo " " >> $out
    echo " " >> $out
    echo 'rm -rf $scratch' >> $out
    chmod +x $out
fi

