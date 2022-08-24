#!/bin/bash
#SBATCH --job-name=2kod_1d_we_c2-20-100_v01
#SBATCH --output=job_logs/%j_slurm.out
#SBATCH --error=job_logs/%j_slurm.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cluster=gpu
#SBATCH --partition=gtx1080
#SBATCH --gres=gpu:4
#SBATCH --mem=16g
#SBATCH --time=144:00:00
#SBATCH --mail-user=dty7@pitt.edu
#SBATCH --mail-type=END,FAIL,BEGIN

set -x
cd $SLURM_SUBMIT_DIR
source env.sh || exit 1

env | sort

cd $WEST_SIM_ROOT
SERVER_INFO=$WEST_SIM_ROOT/west_zmq_info-$SLURM_JOBID.json

# start server
w_run --work-manager=zmq --n-workers=0 --zmq-mode=master --zmq-write-host-info=$SERVER_INFO --zmq-comm-mode=tcp &> west-$SLURM_JOBID.log &

# wait on host info file up to one minute
for ((n=0; n<60; n++)); do
    if [ -e $SERVER_INFO ] ; then
        echo "== server info file $SERVER_INFO =="
        cat $SERVER_INFO
        break
    fi
    sleep 1
done

# exit if host info file doesn't appear in one minute
if ! [ -e $SERVER_INFO ] ; then
    echo 'server failed to start'
    exit 1
fi

# start clients, with the proper number of cores on each

scontrol show hostname $SLURM_NODELIST >& $WEST_SIM_ROOT/job_logs/SLURM_NODELIST.log

# change --n-workers to # gpus for each node (--ntasks-per-node)
for node in $(scontrol show hostname $SLURM_NODELIST); do
    ssh -o StrictHostKeyChecking=no $node $PWD/node.sh $SLURM_SUBMIT_DIR $SLURM_JOBID $node $CUDA_VISIBLE_DEVICES --work-manager=zmq --n-workers=4 --zmq-mode=client --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &
done


wait
