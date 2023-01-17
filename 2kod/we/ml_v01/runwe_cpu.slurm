#!/bin/bash
#SBATCH --job-name=2kod_1d_we
#SBATCH --output=job_logs/slurm.out
#SBATCH --error=job_logs/slurm.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --cluster=smp
#SBATCH --partition=smp
#SBATCH --mem=16g
#SBATCH --time=23:59:00
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL,BEGIN

set -x
cd $SLURM_SUBMIT_DIR

# Make sure environment is set
source env.sh

# Clean up
#rm -f west.log

# Run w_run
w_run --work-manager processes "$@" &> west-$SLURM_JOBID.log
