#!/bin/bash
#
# init.sh
#
# Initialize the WESTPA simulation, creating initial states (istates) and the
# main WESTPA data file, west.h5. 
#
# If you run this script after starting the simulation, the data you generated
# will be erased!
#

source env.sh

# Make sure that seg_logs (log files for each westpa segment), traj_segs (data
# from each trajectory segment), and istates (initial states for starting new
# trajectories) directories exist and are empty. 
#rm -rf traj_segs seg_logs istates west.h5 
rm -rf *.log traj_segs seg_logs istates west.h5 job_logs west_zmq_* 
mkdir   seg_logs traj_segs istates job_logs

# Set pointer to bstate and tstate
BSTATE_ARGS="--bstate-file $WEST_SIM_ROOT/bstates/bstates.txt"
TSTATE_ARGS="--tstate-file $WEST_SIM_ROOT/tstate.file"

# Run w_init
w_init $BSTATE_ARGS $TSTATE_ARGS --segs-per-state 8 --work-manager=threads "$@"

