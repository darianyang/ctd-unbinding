#!/bin/bash

if [ -n "$SEG_DEBUG" ] ; then
  set -x
  env | sort
fi

# for multiple basis states
#TMP=$(mktemp -u)
#echo "MADE TMP: $TMP"

cd $WEST_SIM_ROOT/common_files

CMD="     parm $WEST_SIM_ROOT/common_files/2kod_m01_solv.prmtop \n" 
CMD="$CMD trajin $WEST_STRUCT_DATA_REF \n"
CMD="$CMD autoimage \n"
CMD="$CMD reference $WEST_SIM_ROOT/bstates/05_eq3.rst \n"
# binding rmsd of m1 
CMD="$CMD rms Fit_M2 :94-163&!@H= reference \n"
CMD="$CMD rms RMS_M1 :41,42&!@H= reference nofit out pcoord.dat \n"
# binding rmsd of m2
CMD="$CMD rms Fit_M1 :6-75&!@H= reference \n"
CMD="$CMD rms RMS_M2 :129,130&!@H= reference nofit out pcoord.dat \n"
# COM distance between monomers
CMD="$CMD distance m1-m2-dist :1-75&!@H= :89-163&!@H= out pcoord.dat \n"
# min constact distance which defines tstate conditions
CMD="$CMD nativecontacts mindist :1-88&!@H= :89-176$!@H= out pcoord.dat \n"
CMD="$CMD go \n"

echo -e "$CMD" | cpptraj #$CPPTRAJ

# before this had parentheses but it didn't work in terms of the permissions
# this was more so before using updated we 2.0 setup
#paste < $TMP | tail -n +2 | awk {'print $2'} > $WEST_PCOORD_RETURN
#rm -v $TMP

# based on the final frame value
m1_rms=$(cat pcoord.dat | tail -1 | awk '{print $1}')
m2_rms=$(cat pcoord.dat | tail -1 | awk '{print $2}')

echo M1: $m1_rms and M2: $m2_rms

# save either m1 or m2 rmsd, whichever is larger
if [[ $(echo "if (${m1_rms} > ${m2_rms}) 1 else 0" | bc) -eq 1 ]]; then
    echo "${m1_rms} > ${m2_rms}"
    paste <(cat pcoord.dat | tail -n +2 | awk '{print $2}') <(cat pcoord.dat | tail -n +2 | awk '{print $4}') <(cat pcoord.dat | tail -n +2 | awk '{print $7}') > $WEST_PCOORD_RETURN
else
    echo "${m1_rms} <= ${m2_rms}"
    paste <(cat pcoord.dat | tail -n +2 | awk '{print $3}') <(cat pcoord.dat | tail -n +2 | awk '{print $4}') <(cat pcoord.dat | tail -n +2 | awk '{print $7}') > $WEST_PCOORD_RETURN
fi

if [ -n "$SEG_DEBUG" ] ; then
  head -v $WEST_PCOORD_RETURN
fi

