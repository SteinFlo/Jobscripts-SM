#!/bin/bash

container='singularity exec --fusemount "container:sshfs godot3:/localdisk/.fstein /data/fstein/mnt" --bind /data/fstein:/data/fstein /data/fstein/builds/ITensor-julia-wo.sif'
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

    out="/data/fstein/slurmscripts/Fij/Fij-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_dt${dt}_k${k1}-${kstep}-${k2}_ord${order}_cut${cutoff}_${timestamp}.sh"



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"   >> $out 
    echo "#SBATCH --requeue"   >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 
    echo "#SBATCH -t 7-00:00"         >> $out 

    echo " " >> $out 
    #echo container=\''singularity exec --fusemount "container:sshfs godot3:/localdisk/.fstein /data/fstein/mnt" --bind /data/fstein:/data/fstein /data/fstein/builds/ITensor-julia-wo.sif'\' >> $out
    #echo 'GSscript="/data/fstein/drivers/run_DMRG_GS.sh"' >> $out
    #echo 'TEscript="/data/fstein/drivers/run_FermiStrTE.jl"' >> $out
    echo " " >> $out 

    for k in $(seq $k1 $kstep $k2); do
        if [ $k != 1 ]; then 
        echo " && \\" >> $out 
        fi
        k0=$(python3 -c "print(2*$k)") 
        t=$(python3 -c "print($dt*$k)") 
        echo -n "$container" $Fijscript "$N $d $truncation $x  $mg $l0 $t $k0 $k $order $cutoff" >> $out
    done
    chmod +x $out
fi

