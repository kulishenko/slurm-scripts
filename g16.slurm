#!/bin/bash -l
#SBATCH -J g16-linda

# Max run time (3 months)
#SBATCH -t 90-00:00:00
#

# 1 linda worker per server
#SBATCH --ntasks-per-node=1
#SBATCH -c 24

# Specify slurm partition
#SBATCH --partition=normal

# Errors
#SBATCH --error=Job.%J.stderr

# Standard Output 
#SBATCH --output=Job.%J.out

# Run using a group account
#SBATCH -A gaussian

# E-mail settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=user@example.com

JobFile=${1}


# Remove options for parallel run
sed -i '/NProcShared/Id; /NProcLinda/Id; /LindaWorkers/Id' ${1}

# Load the environment module
module load gaussian/g16.c01

# Recommended somewhere
export OMP_NUM_THREADS=1

# Next lines are there for Linda to know what nodes to run on (and we'd like to run it over 10GbE network)
NodeList="$(srun hostname -s | sed -e 's/$/-bond0/' | sort -u | xargs)"

export GAUSS_LFLAGS='-nodelist "'$NodeList'" -opt "Tsnet.Node.lindarsharg: ssh"'
export GAUSS_SCRDIR=${GAUSS_SCRDIR}/${USER}/${SLURM_JOBID}
mkdir -p $GAUSS_SCRDIR

ParOptions="%NProcLinda=${SLURM_NNODES}\n%NProcShared=${SLURM_CPUS_PER_TASK}"

# Write number of Linda Workers to a Job file
echo -e "${ParOptions}\n$(cat $JobFile)\n" > $JobFile
sed -i -e "/link[0-9]/Ia ${ParOptions}" $JobFile

TASK_NAME=$(echo ${1%.*})

time $g16root/g16/g16 ${JobFile} Job.${SLURM_JOBID}.${TASK_NAME}.log
