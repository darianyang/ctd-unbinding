#!/bin/bash

ITER=450
TRAJ=12

cat << EOF > autoimage.cpp
parm ../common_files/2kod_m01_dry.prmtop
trajin ${ITER}_${TRAJ}.ncdf
autoimage :38
trajout ${ITER}_${TRAJ}_auto.nc
go
quit
EOF

cpptraj -i autoimage.cpp

rm -v autoimage.cpp

