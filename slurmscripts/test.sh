#!/bin/bash
#SBATCH --partition=physics
#SBATCH -c 10
#SBATCH --mem 100000
 
scratch=/scr/$SLURM_JOB_ID
mntpoint=$scratch/mnt

mkdir -p $mntpoint

driver=$scratch/driver
container=$scratch/container.sif

cp /data/fstein/builds/ITensor-julia-wo.sif $container
cp /data/fstein/drivers/run_DMRG_GS.sh $driver

singularity exec --fusemount "container:sshfs godot3:/localdisk/.fstein $mntpoint"  $container $driver 0 0 4 40 5p 

rm -rf $scratch
