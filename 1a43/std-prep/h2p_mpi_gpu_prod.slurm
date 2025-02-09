#!/bin/bash
#SBATCH --job-name=2kod_m01_PROD_v00
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=2 
#SBATCH --cluster=gpu 
#SBATCH --gres=gpu:2
#SBATCH --partition=gtx1080 
#SBATCH --time=47:59:59 
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=slurm.out 
#SBATCH --error=slurm.err 

# load appropriate modules.  First purge all modules then load in intel (a prereq for loading in amber) and then amber 
module purge
module load intel/2017.3.196
module load amber/18

# echo commands to stdout
set -x

export DO_PARALLEL="mpirun -np 2"

# Executable
SANDER=pmemd.cuda.MPI

# Amber input files and output name
INP=06_prod.in
TOP=2kod_m01_solv.prmtop
CRD=05_eq3.rst
OUT=06_prod

$DO_PARALLEL \
$SANDER  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
        -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.nc

