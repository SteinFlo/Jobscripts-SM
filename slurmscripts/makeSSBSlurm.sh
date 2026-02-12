#!/bin/bash

container='singularity exec --fusemount "container:sshfs godot3:/localdisk/.fstein /data/fstein/mnt" --bind /data/fstein:/data/fstein /data/fstein/builds/ITensor-julia-wo.sif'
TEscript="/data/fstein/drivers/run_SSBTE.jl"
GSscript="/data/fstein/drivers/run_DMRG_GS.sh"

if [ "$#" -ne 16 ]; then
    echo "Number of parameters given: "$# ", needs 16." 
    echo "Usage:" 
    echo "makeStringSS.sh N d truncation x m/g l0 N1 N2 dt k1 kstep k2 order cutoff cores mem"
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
    N2=$8
    dt=$9
    k1=${10}
    kstep=${11}
    k2=${12}
    order=${13}
    cutoff=${14}

    cores=${15}
    mem=${16}

    timestamp=$(date +%F_%T)

    out="/data/fstein/slurmscripts/SSBStrTE/S-N${N}_d${dimsymb}_x${x}_mg${mg}_l0${l0}_N1-${N1}_N2-${N2}_dt${dt}_k${k1}-${kstep}-${k2}_ord${order}_cut${cutoff}_${timestamp}.sh"



    echo "#!/bin/bash"                  >> $out 
    echo "#SBATCH --partition=physics"   >> $out 
    echo "#SBATCH --requeue"   >> $out 
    echo "#SBATCH -c ${cores}"          >> $out 
    echo "#SBATCH --mem ${mem}"         >> $out 

    echo " " >> $out 
    #echo container=\''singularity exec --fusemount "container:sshfs godot3:/localdisk/.fstein /data/fstein/mnt" --bind /data/fstein:/data/fstein /data/fstein/builds/ITensor-julia-wo.sif'\' >> $out
    #echo 'GSscript="/data/fstein/drivers/run_DMRG_GS.sh"' >> $out
    #echo 'TEscript="/data/fstein/drivers/run_FermiStrTE.jl"' >> $out
    echo " " >> $out 

    echo -n "$container" $GSscript "$mg $l0 $x $N $dimsymb" >> $out
    for k in $(seq $k1 $kstep $k2); do
        echo " && \\" >> $out 
        echo -n "$container" $TEscript "$N $d $truncation $x  $mg $l0 $N1 $N2 $dt $k $order $cutoff" >> $out
    done
    chmod +x $out
fi

