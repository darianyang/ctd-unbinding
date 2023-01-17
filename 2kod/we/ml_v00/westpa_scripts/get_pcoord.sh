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
#CMD="     parm $WEST_SIM_ROOT/common_files/2kod_m01_dry.prmtop \n" 
CMD="$CMD trajin $WEST_STRUCT_DATA_REF \n"
#CMD="$CMD trajin $WEST_SIM_ROOT/test_runseg/seg.nc \n"
#CMD="$CMD trajin $WEST_SIM_ROOT/bstates/05_eq3.rst \n"
CMD="$CMD autoimage anchor :38 \n"
CMD="$CMD reference $WEST_SIM_ROOT/bstates/05_eq3.rst \n"

# binding rmsd of m1 
#CMD="$CMD rms Fit_M2 :94-163&!@H= reference \n"
#CMD="$CMD rms RMS_M1 :41,42&!@H= reference nofit out pcoord.dat \n"
# binding rmsd of m2
#CMD="$CMD rms Fit_M1 :6-75&!@H= reference \n"
#CMD="$CMD rms RMS_M2 :129,130&!@H= reference nofit out pcoord.dat \n"

# get the overall RMSD of W184 and M185
CMD="$CMD rms Fit :6-75,94-163&!@H= reference \n"
CMD="$CMD rms RMS_W184_M185 :41,42,129,130&!@H= reference nofit out pcoord.dat \n"
# COM distance between monomers
CMD="$CMD distance m1-m2-dist :1-75&!@H= :89-163&!@H= out pcoord.dat \n"
# min constact distance which defines tstate conditions
CMD="$CMD nativecontacts mindist :1-88&!@H= :89-176$!@H= out pcoord.dat \n"

# W184 to opposing monomer distance matrix
# distance matrix averages over all frames, have to do it manually instead
#CMD="$CMD matrix dist :89-176@CA :41@CA byres out m1w184_m2_dmat.dat \n"
#CMD="$CMD matrix dist :1-88@CA :129@CA byres out m2w184_m1_dmat.dat \n"

# loop all residues of a single monomer
for I in {1..88} ; do
    CMD="$CMD distance m1w184_m2_${I} :${I}@CA :41@CA out m1w184_m2_dmat.dat \n"
    CMD="$CMD distance m2w184_m1_${I} :$(($I + 88))@CA :129@CA out m2w184_m1_dmat.dat \n"
done
CMD="$CMD go \n"

echo -e "$CMD" | cpptraj #$CPPTRAJ

# before this had parentheses but it didn't work in terms of the permissions
# this was more so before using updated we 2.0 setup
#paste < $TMP | tail -n +2 | awk {'print $2'} > $WEST_PCOORD_RETURN
#rm -v $TMP

## based on the final frame value
#m1_rms=$(cat pcoord.dat | tail -1 | awk '{print $2}')
#m2_rms=$(cat pcoord.dat | tail -1 | awk '{print $3}')
#
#echo M1: $m1_rms and M2: $m2_rms
#
## save either m1 or m2 rmsd, whichever is larger
#if [[ $(echo "if (${m1_rms} > ${m2_rms}) 1 else 0" | bc) -eq 1 ]]; then
#    echo "${m1_rms} > ${m2_rms}"
#    paste <(cat pcoord.dat | tail -n +2 | awk '{print $2}') <(cat pcoord.dat | tail -n +2 | awk '{print $4}') <(cat pcoord.dat | tail -n +2 | awk '{print $7}') > $WEST_PCOORD_RETURN
#else
#    echo "${m1_rms} <= ${m2_rms}"
#    paste <(cat pcoord.dat | tail -n +2 | awk '{print $3}') <(cat pcoord.dat | tail -n +2 | awk '{print $4}') <(cat pcoord.dat | tail -n +2 | awk '{print $7}') > $WEST_PCOORD_RETURN
#fi

# old 3d pcoord (actually 2d)
#paste <(cat pcoord.dat | tail -n +2 | awk '{print $2}') <(cat pcoord.dat | tail -n +2 | awk '{print $3}') <(cat pcoord.dat | tail -n +2 | awk '{print $6}') > $WEST_PCOORD_RETURN
# updated 2d (actually 1d)
#paste <(cat pcoord.dat | tail -n +2 | awk '{print $3}') <(cat pcoord.dat | tail -n +2 | awk '{print $6}') > $WEST_PCOORD_RETURN

# calc weighted avgs
python weighted_dmat_pcoord.py m2w184_m1_dmat.dat $WEST_SIM_ROOT/common_files/m2w184_m1_dmat_weights.txt
paste <(cat w_avgs.txt) <(cat pcoord.dat | tail -n +2 | awk '{print $6}') > $WEST_PCOORD_RETURN


if [ -n "$SEG_DEBUG" ] ; then
  head -v $WEST_PCOORD_RETURN
fi

