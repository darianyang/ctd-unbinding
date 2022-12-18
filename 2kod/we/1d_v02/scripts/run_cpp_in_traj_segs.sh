#!/bin/bash
# go into traj_segs directories and run cpptraj commands on each
# useful for stripping water from seg.nc or seg.rst

CPP=rst_strip.cpp

# loop over all iteration/seg traj paths
for IT in {000001..000200} ; do
    for SEG in traj_segs/$IT/*/ ; do 
        #mv ${SEG}seg.rst ${SEG}seg-solv.rst
        cd $SEG
        #rm *.rst.*
        echo "parm ../../../common_files/1A43_solv.prmtop" > $CPP 
        echo "trajin seg-solv.rst" >> $CPP
        echo "strip :WAT,Cl-" >> $CPP
        echo "trajout seg-dry.rst restart" >> $CPP
        echo "go" >> $CPP 
        cpptraj -i $CPP &&
        rm $CPP
        cd ../../../
    done
done

