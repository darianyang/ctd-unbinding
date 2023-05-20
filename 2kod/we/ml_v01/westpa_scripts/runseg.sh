#!/bin/bash

if [ -n "$SEG_DEBUG" ] ; then
  set -x
  env | sort
fi

cd $WEST_SIM_ROOT
mkdir -pv $WEST_CURRENT_SEG_DATA_REF
cd $WEST_CURRENT_SEG_DATA_REF

PRMTOP=2kod_m01_solv.prmtop

ln -sv $WEST_SIM_ROOT/common_files/$PRMTOP .

if [ "$WEST_CURRENT_SEG_INITPOINT_TYPE" = "SEG_INITPOINT_CONTINUES" ]; then
  sed "s/RAND/$WEST_RAND16/g" $WEST_SIM_ROOT/common_files/md.in > md.in
  ln -sv $WEST_PARENT_DATA_REF/seg.ncrst ./parent.ncrst
elif [ "$WEST_CURRENT_SEG_INITPOINT_TYPE" = "SEG_INITPOINT_NEWTRAJ" ]; then
  sed "s/RAND/$WEST_RAND16/g" $WEST_SIM_ROOT/common_files/md.in > md.in
  ln -sv $WEST_PARENT_DATA_REF ./parent.ncrst
fi

export CUDA_DEVICES=(`echo $CUDA_VISIBLE_DEVICES_ALLOCATED | tr , ' '`)
export CUDA_VISIBLE_DEVICES=${CUDA_DEVICES[$WM_PROCESS_INDEX]}

echo "RUNSEG.SH: CUDA_VISIBLE_DEVICES_ALLOCATED = " $CUDA_VISIBLE_DEVICES_ALLOCATED
echo "RUNSEG.SH: WM_PROCESS_INDEX = " $WM_PROCESS_INDEX
echo "RUNSEG.SH: CUDA_VISIBLE_DEVICES = " $CUDA_VISIBLE_DEVICES

$PMEMD -O -i md.in   -p $PRMTOP  -c parent.ncrst \
          -r seg.ncrst -x seg.nc  -o seg.log   -inf seg.nfo

# cpptraj input
CMD="     parm $WEST_SIM_ROOT/common_files/$PRMTOP \n" 
CMD="$CMD trajin $WEST_CURRENT_SEG_DATA_REF/parent.ncrst \n"
CMD="$CMD trajin $WEST_CURRENT_SEG_DATA_REF/seg.nc \n"
CMD="$CMD reference $WEST_SIM_ROOT/bstates/05_eq3.ncrst name [ref] \n"
CMD="$CMD reference /ix/lchong/dty7/ctd-unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [nmr] \n"
CMD="$CMD reference /ix/lchong/dty7/ctd-unbinding/1a43/std-prep/1a43_solv.pdb :* name [xtal] \n"
CMD="$CMD autoimage anchor :38 \n"

# PCOORD CALC:
# binding rmsd of m1 
#CMD="$CMD rms Fit_M2 :94-163&!@H= reference \n"
#CMD="$CMD rms RMS_M1 :41,42&!@H= nofit out pcoord.dat \n"
# binding rmsd of m2
#CMD="$CMD rms Fit_M1 :6-75&!@H= reference \n"
#CMD="$CMD rms RMS_M2 :129,130&!@H= nofit out pcoord.dat \n"
# get the overall RMSD of W184 and M185
CMD="$CMD rms Fit :6-75,94-163&!@H= ref [ref] \n"
CMD="$CMD rms RMS_W184_M185 :41,42,129,130&!@H= nofit out pcoord.dat \n"
# COM distance between monomers
CMD="$CMD distance m1-m2-dist :1-75&!@H= :89-163&!@H= out pcoord.dat \n"
# min constact distance which defines tstate conditions
CMD="$CMD nativecontacts mindist :1-88&!@H= :89-176$!@H= out pcoord.dat \n"

# NMR ref rms calcs
CMD="$CMD rms Fit_M2_NMR :94-163&!@H= ref [nmr] \n"
CMD="$CMD rms RMS_M1_NMR :6-75&!@H= ref [nmr] nofit mass time 1 out rms_m1_nmr.dat \n"
CMD="$CMD rms RMS_H9M1_NMR :36-49&!@H= nofit ref [nmr] out rms_h9m1_nmr.dat mass time 1 \n"

CMD="$CMD rms Fit_M1_NMR :6-75&!@H= ref [nmr] \n"
CMD="$CMD rms RMS_M2_NMR :94-163&!@H= ref [nmr] nofit mass time 1 out rms_m2_nmr.dat \n"
CMD="$CMD rms RMS_H9M2_NMR :124-137&!@H= nofit ref [nmr] out rms_h9m2_nmr.dat mass time 1 \n"

CMD="$CMD rms RMS_Heavy_NMR :6-75,94-163&!@H= ref [nmr] mass time 1 out rms_heavy_nmr.dat \n"
CMD="$CMD rms RMS_Backbone_NMR :6-75,94-163@CA,C,O,N ref [nmr] mass time 1 out rms_bb_nmr.dat \n"
CMD="$CMD rms RMS_Dimer_Int_NMR :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [nmr] mass time 1 out rms_dimer_int_nmr.dat \n"
CMD="$CMD rms RMS_Key_Int_NMR :38,41,42,126,129,130&!@H= ref [nmr] mass time 1 out rms_key_int_nmr.dat \n"

# XTAL ref rms calcs
CMD="$CMD rms Fit_M2_XTAL :94-163&!@H= ref [xtal] \n"
CMD="$CMD rms RMS_M1_XTAL :6-75&!@H= ref [xtal] nofit mass time 1 out rms_m1_xtal.dat \n"
CMD="$CMD rms RMS_H9M1_XTAL :36-49&!@H= nofit ref [xtal] out rms_h9m1_xtal.dat mass time 1 \n"

CMD="$CMD rms Fit_M1_XTAL :6-75&!@H= ref [xtal] \n"
CMD="$CMD rms RMS_M2_XTAL :94-163&!@H= ref [xtal] nofit mass time 1 out rms_m2_xtal.dat \n"
CMD="$CMD rms RMS_H9M2_XTAL :124-137&!@H= nofit ref [xtal] out rms_h9m2_xtal.dat mass time 1 \n"

CMD="$CMD rms RMS_Heavy_XTAL :6-75,94-163&!@H= ref [xtal] mass time 1 out rms_heavy_xtal.dat \n"
CMD="$CMD rms RMS_Backbone_XTAL :6-75,94-163@CA,C,O,N ref [xtal] mass time 1 out rms_bb_xtal.dat \n"
CMD="$CMD rms RMS_Dimer_Int_XTAL :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [xtal] mass time 1 out rms_dimer_int_xtal.dat \n"
CMD="$CMD rms RMS_Key_Int_XTAL :38,41,42,126,129,130&!@H= ref [xtal] mass time 1 out rms_key_int_xtal.dat \n"

# dimer angle calc, vector based
CMD="$CMD vector D1 :1-75@CA,C,O,N :39@CA,C,O,N  \n"
CMD="$CMD vector D2 :89-163@CA,C,O,N :127@CA,C,O,N  \n"
CMD="$CMD vectormath vec1 D1 vec2 D2 out 1_75_39_c2.dat name 1_75_39_c2 dotangle \n"
# using backbone N of: T186 M1 --- M1 and M2 V181 --- T186 M2
CMD="$CMD angle helix_angle :43@N :38,126@N :131@N out angle_3pt.dat mass \n"

# rog, sasa, dssp, contacts 
CMD="$CMD radgyr RoG :1-176 out rog.dat mass nomax \n"
CMD="$CMD radgyr RoG-cut :6-75,94-163 out rog.dat mass nomax \n"
CMD="$CMD surf Total_SASA :1-176 out total_sasa.dat \n"
CMD="$CMD secstruct Secondary_Struct out secondary_struct.dat :1-176 \n"
CMD="$CMD nativecontacts name Num_Inter_Contacts :1-88&!@H= :89-176&!@H= byresidue distance 4.5 out inter_contacts.dat ref [nmr] \n"
CMD="$CMD nativecontacts name Num_Intra_Contacts :1-176&!@H= byresidue distance 4.5 out intra_contacts.dat ref [nmr] \n"

# calculate multiple distances
# calc distance between (COM) both O eps of E175 and H eps 1 of W184
CMD="$CMD distance M1-E175-Oe_M2-W184-He1 :32@OE1,OE2 :129@HE1 out dist_M1-E175_M2-W184.dat \n"
CMD="$CMD distance M2-E175-Oe_M1-W184-He1 :120@OE1,OE2 :41@HE1 out dist_M2-E175_M1-W184.dat \n"
# calc distance between (COM) both O eps of E175 and HG1 of T148
CMD="$CMD distance M1-E175-Oe_M1-T148-HG1 :32@OE1,OE2 :5@HG1 out dist_M1-E175_M1-T148.dat \n"
CMD="$CMD distance M2-E175-Oe_M2-T148-HG1 :120@OE1,OE2 :93@HG1 out dist_M2-E175_M2-T148.dat \n"
# calc inter monomer distance using COMs of M1 and M2
CMD="$CMD distance M1-M2-COM :6-75&!@H= :94-163&!@H= out dist_M1-M2_COM.dat \n"
# calc inter monomer distance using bottom of the helix
CMD="$CMD distance M1-M2-L46 :46@N :134@N out dist_M1-M2_L46.dat \n"

# dihedral angles of E175
CMD="$CMD multidihedral phi resrange 32-32 out M1_E175_phi.dat \n"
CMD="$CMD multidihedral psi resrange 32-32 out M1_E175_psi.dat \n"
CMD="$CMD multidihedral dihtype chi1:N:CA:CB:CG "
CMD="$CMD               dihtype chi2:CA:CB:CG:CD "
CMD="$CMD               dihtype chi3:CB:CG:CD:OE1 "
CMD="$CMD               resrange 32-32"
CMD="$CMD               out M1_E175_chi123.dat \n"
CMD="$CMD multidihedral phi resrange 120-120 out M2_E175_phi.dat \n"
CMD="$CMD multidihedral psi resrange 120-120 out M2_E175_psi.dat \n"
CMD="$CMD multidihedral dihtype chi1:N:CA:CB:CG "
CMD="$CMD               dihtype chi2:CA:CB:CG:CD "
CMD="$CMD               dihtype chi3:CB:CG:CD:OE1 "
CMD="$CMD               resrange 120-120"
CMD="$CMD               out M2_E175_chi123.dat \n"

# loop all residues of a single monomer
for I in {1..88} ; do
    CMD="$CMD distance m1w184_m2_${I} :${I}@CA :41@CA out m1w184_m2_dmat.dat \n"
    CMD="$CMD distance m2w184_m1_${I} :$(($I + 88))@CA :129@CA out m2w184_m1_dmat.dat \n"
done

# done
CMD="$CMD go \n"

echo -e "$CMD" | $CPPTRAJ

# strip nc file
CMD="     parm $WEST_SIM_ROOT/common_files/$PRMTOP \n"
CMD="$CMD trajin $WEST_CURRENT_SEG_DATA_REF/seg.nc \n"
CMD="$CMD autoimage anchor :38 \n"
# strip and replace solv nc file
CMD="$CMD strip :WAT,Cl-,Na+ \n" 
CMD="$CMD trajout $WEST_CURRENT_SEG_DATA_REF/seg-nowat.nc \n"
CMD="$CMD go \n"

echo -e "$CMD" | $CPPTRAJ

# strip rst file
CMD="     parm $WEST_SIM_ROOT/common_files/$PRMTOP \n"
CMD="$CMD trajin $WEST_CURRENT_SEG_DATA_REF/seg.ncrst \n"
CMD="$CMD autoimage anchor :38 \n"
# strip and replace solv rst file
CMD="$CMD strip :WAT,Cl-,Na+ \n" 
# need to have separate rst stripper
CMD="$CMD trajout $WEST_CURRENT_SEG_DATA_REF/seg-nowat.ncrst  restart \n"
CMD="$CMD go \n"

echo -e "$CMD" | $CPPTRAJ

### PCOORD ###
# based on the final frame value
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

#paste <(cat pcoord.dat | tail -n +2 | awk '{print $2}') <(cat pcoord.dat | tail -n +2 | awk '{print $3}') <(cat pcoord.dat | tail -n +2 | awk '{print $6}') > $WEST_PCOORD_RETURN
#paste <(cat pcoord.dat | tail -n +2 | awk '{print $3}') <(cat pcoord.dat | tail -n +2 | awk '{print $6}') > $WEST_PCOORD_RETURN

# calc weighted avgs
python $WEST_SIM_ROOT/common_files/weighted_dmat_pcoord.py m1w184_m2_dmat.dat $WEST_SIM_ROOT/common_files/m1w184_m2_dmat_weights.txt w_avgs_m1.txt
python $WEST_SIM_ROOT/common_files/weighted_dmat_pcoord.py m2w184_m1_dmat.dat $WEST_SIM_ROOT/common_files/m2w184_m1_dmat_weights.txt w_avgs_m2.txt
# calc pdt of the weighted avgs
python $WEST_SIM_ROOT/scripts/calc_pdt.py w_avgs_m1.txt w_avgs_m2.txt w_avgs_pdt.txt
paste <(cat w_avgs_pdt.txt) <(cat pcoord.dat | tail -n +2 | awk '{print $6}') > $WEST_PCOORD_RETURN

### AUXDATA ###

# pcoord data
cat pcoord.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_184_185_RETURN
cat pcoord.dat | tail -n +2 | awk {'print $3'} > $WEST_COM_DIST_RETURN
cat pcoord.dat | tail -n +2 | awk {'print $6'} > $WEST_MIN_DIST_RETURN

# nmr ref rms
cat rms_m1_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_M1_NMR_RETURN
cat rms_h9m1_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_H9M1_NMR_RETURN
cat rms_m2_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_M2_NMR_RETURN
cat rms_h9m2_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_H9M2_NMR_RETURN
cat rms_heavy_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_HEAVY_NMR_RETURN
cat rms_bb_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_BB_NMR_RETURN
cat rms_dimer_int_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_DIMER_INT_NMR_RETURN
cat rms_key_int_nmr.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_KEY_INT_NMR_RETURN

# xtal ref rms
cat rms_m1_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_M1_XTAL_RETURN
cat rms_h9m1_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_H9M1_XTAL_RETURN
cat rms_m2_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_M2_XTAL_RETURN
cat rms_h9m2_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_H9M2_XTAL_RETURN
cat rms_heavy_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_HEAVY_XTAL_RETURN
cat rms_bb_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_BB_XTAL_RETURN
cat rms_dimer_int_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_DIMER_INT_XTAL_RETURN
cat rms_key_int_xtal.dat | tail -n +2 | awk {'print $2'} > $WEST_RMS_KEY_INT_XTAL_RETURN

# angles
cat 1_75_39_c2.dat | tail -n +2 | awk {'print $2'} > $WEST_1_75_39_C2_RETURN
cat angle_3pt.dat | tail -n +2 | awk {'print $2'} > $WEST_ANGLE_3PT_RETURN

# rog, sasa, dssp, contacts
cat rog.dat | tail -n +2 | awk {'print $2'} > $WEST_ROG_RETURN
cat rog.dat | tail -n +2 | awk {'print $3'} > $WEST_ROG_CUT_RETURN
cat total_sasa.dat | tail -n +2 | awk {'print $2'} > $WEST_TOTAL_SASA_RETURN
cat secondary_struct.dat | tail -n +2 | awk {'print $7'} > $WEST_SECONDARY_STRUCT_RETURN
cat inter_contacts.dat | tail -n +2 | awk {'print $2'} > $WEST_INTER_NC_RETURN
cat inter_contacts.dat | tail -n +2 | awk {'print $3'} > $WEST_INTER_NNC_RETURN
cat intra_contacts.dat | tail -n +2 | awk {'print $2'} > $WEST_INTRA_NC_RETURN
cat intra_contacts.dat | tail -n +2 | awk {'print $3'} > $WEST_INTRA_NNC_RETURN

# distances
cat dist_M1-E175_M2-W184.dat | tail -n +2 | awk {'print $2'} > $WEST_M1E175_M2W184_RETURN
cat dist_M2-E175_M1-W184.dat | tail -n +2 | awk {'print $2'} > $WEST_M2E175_M1W184_RETURN
cat dist_M1-E175_M1-T148.dat | tail -n +2 | awk {'print $2'} > $WEST_M1E175_M1T148_RETURN
cat dist_M2-E175_M2-T148.dat | tail -n +2 | awk {'print $2'} > $WEST_M2E175_M2T148_RETURN
cat dist_M1-M2_COM.dat | tail -n +2 | awk {'print $2'} > $WEST_M1M2_COM_RETURN
cat dist_M1-M2_L46.dat | tail -n +2 | awk {'print $2'} > $WEST_M1M2_L46_RETURN

# W184 to opposite monomer distances (printing all columns to one aux dataset)
cat m1w184_m2_dmat.dat | tail -n +2 | awk '{$1=""; print $0}' > $WEST_M1W184_M2_DMAT_RETURN
cat m2w184_m1_dmat.dat | tail -n +2 | awk '{$1=""; print $0}' > $WEST_M2W184_M1_DMAT_RETURN

# M1 E175 dihedrals
cat M1_E175_phi.dat | tail -n +2 | awk {'print $2'} > $WEST_M1_E175_PHI_RETURN
cat M1_E175_psi.dat | tail -n +2 | awk {'print $2'} > $WEST_M1_E175_PSI_RETURN
cat M1_E175_chi123.dat | tail -n +2 | awk {'print $2'} > $WEST_M1_E175_CHI1_RETURN
cat M1_E175_chi123.dat | tail -n +2 | awk {'print $3'} > $WEST_M1_E175_CHI2_RETURN
cat M1_E175_chi123.dat | tail -n +2 | awk {'print $4'} > $WEST_M1_E175_CHI3_RETURN
# M2 E175 dihedrals
cat M2_E175_phi.dat | tail -n +2 | awk {'print $2'} > $WEST_M2_E175_PHI_RETURN
cat M2_E175_psi.dat | tail -n +2 | awk {'print $2'} > $WEST_M2_E175_PSI_RETURN
cat M2_E175_chi123.dat | tail -n +2 | awk {'print $2'} > $WEST_M2_E175_CHI1_RETURN
cat M2_E175_chi123.dat | tail -n +2 | awk {'print $3'} > $WEST_M2_E175_CHI2_RETURN
cat M2_E175_chi123.dat | tail -n +2 | awk {'print $4'} > $WEST_M2_E175_CHI3_RETURN

# mdtraj based sasa
python $WEST_SIM_ROOT/common_files/analyze_sasa.py $WEST_CURRENT_SEG_DATA_REF
cat total_sasa_mdt.dat > $WEST_TOTAL_SASA_MDT_RETURN
cat m1_sasa_mdt.dat > $WEST_M1_SASA_MDT_RETURN
cat m2_sasa_mdt.dat > $WEST_M2_SASA_MDT_RETURN

# Clean up
rm -f md.in $PRMTOP parent.ncrst seg.nfo seg.pdb *.dat* *.txt

# remove and replace solvated segment trajectory file
if [ -f "seg-nowat.nc" ]; then
    rm seg.nc &&
    mv seg-nowat.nc seg.nc
fi

