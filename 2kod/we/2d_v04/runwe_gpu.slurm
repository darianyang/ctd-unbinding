#!/bin/bash
#SBATCH --job-name=1a43_1d_we
#SBATCH --output=job_logs/slurm_we.out
#SBATCH --error=job_logs/slurm_we.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cluster=gpu
#SBATCH --partition=gtx1080
#SBATCH --gres=gpu:2
#SBATCH --mem=16g
#SBATCH --time=6:00:00
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
