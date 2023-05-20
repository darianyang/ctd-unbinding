#!/bin/bash
# calculate the aggregate simulation time of WE simulation
# run in base WESTPA sim directory

sim_time=0

for i in traj_segs/*/*; do
    let "sim_time++"
done

echo "total segments = $sim_time"
echo "aggregate simulation time = $((sim_time * 100 / 1000)) ns"
