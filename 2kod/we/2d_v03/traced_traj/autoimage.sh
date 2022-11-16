#!/bin/bash

ITER=$1
TRAJ=$2


cat << EOF > autoimage.cpp
parm ../common_files/2kod_m01_dry.prmtop
trajin ${ITER}_${TRAJ}.ncdf
autoimage
#trajout ${ITER}_${TRAJ}_auto.nc
trajout ${ITER}_${TRAJ}_auto.dcd
go
quit
EOF

cpptraj -i autoimage.cpp

rm -v autoimage.cpp

