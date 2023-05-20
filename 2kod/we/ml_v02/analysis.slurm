#!/bin/bash
#SBATCH --job-name=WE_1A43_AGG_RST_STRIP
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1 
#SBATCH --cluster=invest
#SBATCH --partition=lchong
##SBATCH --mem=16g
#SBATCH --time=23:59:59 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=job_logs/slurm_rst_strip.out 
#SBATCH --error=job_logs/slurm_rst_strip.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge
module load intel/2017.3.196
module load amber/18

# echo commands to stdout
set -x

bash run_cpp_in_traj_segs.sh
