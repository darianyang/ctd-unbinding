#!/bin/bash

ITER=295
TRAJ=6


cat << EOF > autoimage.cpp
parm ../common_files/2kod_m01_dry.prmtop
trajin ${ITER}_${TRAJ}.ncdf
autoimage
trajout ${ITER}_${TRAJ}_auto.nc
go
quit
EOF

cpptraj -i autoimage.cpp

rm -v autoimage.cpp

