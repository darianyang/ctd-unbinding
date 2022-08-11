#!/bin/bash
# convert multiple rst files to pdb files

PRMTOP=1a43_solv2.prmtop

ambpdb -p $PRMTOP -c 02_min.rst > 02_min.pdb
ambpdb -p $PRMTOP -c 03_eq1.rst > 03_eq1.pdb
ambpdb -p $PRMTOP -c 04_eq2.rst > 04_eq2.pdb
ambpdb -p $PRMTOP -c 05_eq3.rst > 05_eq3.pdb
