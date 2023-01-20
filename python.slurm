#!/bin/bash -l
#SBATCH -J yolov3 

# Max run time (3 months)
#SBATCH -t 90-00:00:00

# Specify slurm partition
#SBATCH --partition=normal

# Tasks per node
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

# Errors
#SBATCH --error=Job.%J.stderr

# Standard Output 
#SBATCH --output=Job.%J.out

# Run using a group account
#SBATCH -A gaussian 

# E-mail settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=user@example.com

# Load the appropriate modules

/opt/python3/bin/python3 ${@} > Job.${SLURM_JOBID}.log

