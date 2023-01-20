#!/bin/bash -l
#SBATCH -J cfour 

# Max run time (3 months)
#SBATCH -t 90-00:00:00
#

# 8 cfour worker per server
#SBATCH --ntasks-per-node=8

# Specify slurm partition
#SBATCH --partition=highmem

# Errors
#SBATCH --error=Job.%J.stderr

# Standard Output 
#SBATCH --output=Job.%J.out

# Run using a group account
#SBATCH -A cfour

# E-mail settings
#SBATCH --mail-type=END
#SBATCH --mail-user=user@example.com

JobFile=${1}

module load cfour/2.1-icc-2018-ompi
export PATH=/opt/hpcx-v2.2.0/ompi-3.1.3-icc/bin/:$PATH

# Recommended somethere
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export CFOUR_NUM_CORES=${SLURM_NTASKS}

# Copy files to scratch on nodes
sbcast ${1} $CFOUR_SCRDIR/ZMAT
sbcast ${CFOUR_ROOT}/basis/GENBAS $CFOUR_SCRDIR/GENBAS

cd $CFOUR_SCRDIR

xcfour > ${SLURM_SUBMIT_DIR}/Job.${SLURM_JOB_ID}.log
