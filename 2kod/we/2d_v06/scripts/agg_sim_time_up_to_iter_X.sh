#!/bin/bash
# calculate the aggregate simulation time of WE simulation
# run in base WESTPA sim directory
# takes 1 arg = iteration to caluclate up to (int)


sim_time=0
ITER_MAX=$1

# here I am using seq instead of C style loop
# seq may be slower due to calling external command
# but this may only be detrimental to large dataset manipulations
# seq can use variables in loop and formatting with X decimals
for i in $(seq -f "%06g" 1 $ITER_MAX); do
    # find and print all directories for a WE iteration, save dir amount (int) 
    seg_count=$(find traj_segs/$i/* -maxdepth 0 -type d | wc -l)
    let "sim_time += seg_count"  
done

echo "for up to iteration $ITER_MAX : total segments = $sim_time"
echo "aggregate simulation time = $((sim_time * 100 / 1000)) ns or $((sim_time * 100)) ps"
echo ""
