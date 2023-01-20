#!/bin/bash -l
#SBATCH -J siesta415 

# Max run time (3 months)
#SBATCH -t 90-00:00:00

# Specify slurm partition
#SBATCH --partition=normal

# Tasks per node
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24

# Errors
#SBATCH --error=Job.%J.stderr

# Standard Output 
#SBATCH --output=Job.%J.out

# Run using a group account
#SBATCH -A siesta

# E-mail settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=user@example.com

# Use all cores
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Load the environment module
module load mkl/2017 # DO NOT USE NEWER MKL VERSIONS! Memory leak is highly possible
module load siesta/4.1.5
module load hpcx/2.2.0/hpcx-ompi-1api 

# Go to the Job Dir and Run

srun siesta ${1}

