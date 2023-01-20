#!/bin/bash -l
#SBATCH -J orca412

# Max run time (3 months)
#SBATCH -t 90-00:00:00

# Specify slurm partition
#SBATCH --partition=normal

# Tasks per node
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24

# Errors
#SBATCH --error=Job.%J.stderr

# Standard Output 
#SBATCH --output=Job.%J.out

# Run using a group account
#SBATCH -A orca

# E-mail settings
#SBATCH --mail-type=ALL
#SBATCH --mail-user=user@example.com

# Load the appropriate modules
module load hpcx/2.2.0/hpcx-ompi-3.1.3
module load orca/4.1.1

# Use all cores
export OMP_NUM_THREADS=1

# Suppress MXM warnings 
export MXM_LOG_LEVEL=error

# Remove PAL option (if exists) and insert the new one
sed -i "/%pal/,+2d;/\!/ a %pal\nnproc ${SLURM_NTASKS}\nend" ${1}

# Create Temporary dir and copy input file on nodes
export TDIR=/scr0/${USER}/${SLURM_JOBID}

TASK_NAME=$(echo ${1%.*})

srun mkdir -p ${TDIR}
sbcast ${1} ${TDIR}/${1}
sbcast ${TASK_NAME}.gbw ${TDIR}/${TASK_NAME}.gbw
#sbcast ${TASK_NAME}.xyz ${TDIR}/${TASK_NAME}.xyz 
for FILE_NAME in *.xyz; do sbcast ${FILE_NAME}.xyz ${TDIR}/${FILE_NAME}.xyz; done

export TMPDIR=${TDIR}
export RSH_COMMAND="/usr/bin/ssh -x"
echo "module load hpcx/2.2.0/hpcx-ompi-3.1.3" >> ~/.bashrc

set -e
${ORCA_PATH}/orca ${TDIR}/${1} > Job.${SLURM_JOBID}.${TASK_NAME}.log 
sed -i '/hpcx-ompi-3.1.3/d' ~/.bashrc

# Copy back the results
export RESULTS_DIR=${SLURM_SUBMIT_DIR}/Job.${SLURM_JOBID}.${TASK_NAME}.results
mkdir -p ${RESULTS_DIR}

#for FILE_NAME in ${TDIR}/*.xyz ${TDIR}/*.gbw ${TDIR}/*.trj;
#do yes | cp -rf ${FILE_NAME} ${RESULTS_DIR}/; done
srun cp -rf ${TDIR}/{*.xyz,*.gbw,*.trj,*.hess} ${RESULTS_DIR}/ 2>/dev/null || :
#srun cp -rf ${TDIR}/*.gbw ${RESULTS_DIR}/ 2>/dev/null || :
#srun cp -rf ${TDIR}/*.trj ${RESULTS_DIR}/ 2>/dev/null || :
