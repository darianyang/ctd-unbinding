#!/bin/bash

PRMTOP=2kod_m01_dry.prmtop

# cpptraj input
CMD="     parm ../../common_files/$PRMTOP \n" 
CMD="$CMD trajin ../500_29_auto.nc 1 last 10 \n"
#CMD="$CMD reference ../../bstates/05_eq3.ncrst name [ref] \n"
CMD="$CMD reference ../../reference/02_min.pdb name [ref] \n"
CMD="$CMD reference /Users/darian/github/ctd-unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [nmr] \n"
CMD="$CMD reference /Users/darian/github/ctd-unbinding/1a43/std-prep/1a43_solv.pdb :* name [xtal] \n"
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
CMD="$CMD rms RMS_W184_M185 :41,42,129,130&!@H= nofit out rms_w_m.dat \n"
## COM distance between monomers
CMD="$CMD distance m1-m2-dist :1-75&!@H= :89-163&!@H= out com_dist.dat \n"
## min constact distance which defines tstate conditions
CMD="$CMD nativecontacts mindist :1-88 :89-176 out min_dist.dat \n"
#CMD="$CMD nativecontacts mindist :1-88&!@H= :89-176&!@H= out min_dist2.dat \n"
#CMD="$CMD nativecontacts mindist :1-88&!@H= :89-176&!@H= distance 6.0 out min_dist2.dat \n"
#CMD="$CMD nativecontacts mindist :1-88 :89-176 distance 4.5 out min_dist45.dat \n"
#CMD="$CMD nativecontacts mindist :1-88 :89-176 distance 6.0 out min_dist6.dat \n"
CMD="$CMD nativecontacts mindist :1-88 :89-176 distance 7.0 out min_dist7.dat \n"
#
## NMR ref rms calcs
#CMD="$CMD rms Fit_M2_NMR :94-163&!@H= ref [nmr] \n"
#CMD="$CMD rms RMS_M1_NMR :6-75&!@H= ref [nmr] nofit mass time 1 out rms_m1_nmr.dat \n"
#CMD="$CMD rms RMS_H9M1_NMR :36-49&!@H= nofit ref [nmr] out rms_h9m1_nmr.dat mass time 1 \n"
#
#CMD="$CMD rms Fit_M1_NMR :6-75&!@H= ref [nmr] \n"
#CMD="$CMD rms RMS_M2_NMR :94-163&!@H= ref [nmr] nofit mass time 1 out rms_m2_nmr.dat \n"
#CMD="$CMD rms RMS_H9M2_NMR :124-137&!@H= nofit ref [nmr] out rms_h9m2_nmr.dat mass time 1 \n"
#
#CMD="$CMD rms RMS_Heavy_NMR :6-75,94-163&!@H= ref [nmr] mass time 1 out rms_heavy_nmr.dat \n"
#CMD="$CMD rms RMS_Backbone_NMR :6-75,94-163@CA,C,O,N ref [nmr] mass time 1 out rms_bb_nmr.dat \n"
#CMD="$CMD rms RMS_Dimer_Int_NMR :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [nmr] mass time 1 out rms_dimer_int_nmr.dat \n"
#CMD="$CMD rms RMS_Key_Int_NMR :38,41,42,126,129,130&!@H= ref [nmr] mass time 1 out rms_key_int_nmr.dat \n"
#
## XTAL ref rms calcs
#CMD="$CMD rms Fit_M2_XTAL :94-163&!@H= ref [xtal] \n"
#CMD="$CMD rms RMS_M1_XTAL :6-75&!@H= ref [xtal] nofit mass time 1 out rms_m1_xtal.dat \n"
#CMD="$CMD rms RMS_H9M1_XTAL :36-49&!@H= nofit ref [xtal] out rms_h9m1_xtal.dat mass time 1 \n"
#
#CMD="$CMD rms Fit_M1_XTAL :6-75&!@H= ref [xtal] \n"
#CMD="$CMD rms RMS_M2_XTAL :94-163&!@H= ref [xtal] nofit mass time 1 out rms_m2_xtal.dat \n"
#CMD="$CMD rms RMS_H9M2_XTAL :124-137&!@H= nofit ref [xtal] out rms_h9m2_xtal.dat mass time 1 \n"
#
#CMD="$CMD rms RMS_Heavy_XTAL :6-75,94-163&!@H= ref [xtal] mass time 1 out rms_heavy_xtal.dat \n"
#CMD="$CMD rms RMS_Backbone_XTAL :6-75,94-163@CA,C,O,N ref [xtal] mass time 1 out rms_bb_xtal.dat \n"
#CMD="$CMD rms RMS_Dimer_Int_XTAL :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [xtal] mass time 1 out rms_dimer_int_xtal.dat \n"
#CMD="$CMD rms RMS_Key_Int_XTAL :38,41,42,126,129,130&!@H= ref [xtal] mass time 1 out rms_key_int_xtal.dat \n"
#
## dimer angle calc, vector based
#CMD="$CMD vector D1 :1-75@CA,C,O,N :39@CA,C,O,N  \n"
#CMD="$CMD vector D2 :89-163@CA,C,O,N :127@CA,C,O,N  \n"
#CMD="$CMD vectormath vec1 D1 vec2 D2 out 1_75_39_c2.dat name 1_75_39_c2 dotangle \n"
## using backbone N of: T186 M1 --- M1 and M2 V181 --- T186 M2
#CMD="$CMD angle helix_angle :43@N :38,126@N :131@N out angle_3pt.dat mass \n"
#
## rog, sasa, dssp, contacts 
#CMD="$CMD radgyr RoG :1-176 out rog.dat mass nomax \n"
#CMD="$CMD radgyr RoG-cut :6-75,94-163 out rog.dat mass nomax \n"
#CMD="$CMD surf Total_SASA :1-176 out total_sasa.dat \n"
#CMD="$CMD secstruct Secondary_Struct out secondary_struct.dat :1-176 \n"
#CMD="$CMD nativecontacts name Num_Inter_Contacts :1-88&!@H= :89-176&!@H= byresidue distance 4.5 out inter_contacts.dat ref [nmr] \n"
#CMD="$CMD nativecontacts name Num_Intra_Contacts :1-176&!@H= byresidue distance 4.5 out intra_contacts.dat ref [nmr] \n"
#
## calculate multiple distances
## calc distance between (COM) both O eps of E175 and H eps 1 of W184
#CMD="$CMD distance M1-E175-Oe_M2-W184-He1 :32@OE1,OE2 :129@HE1 out dist_M1-E175_M2-W184.dat \n"
#CMD="$CMD distance M2-E175-Oe_M1-W184-He1 :120@OE1,OE2 :41@HE1 out dist_M2-E175_M1-W184.dat \n"
## calc distance between (COM) both O eps of E175 and HG1 of T148
#CMD="$CMD distance M1-E175-Oe_M1-T148-HG1 :32@OE1,OE2 :5@HG1 out dist_M1-E175_M1-T148.dat \n"
#CMD="$CMD distance M2-E175-Oe_M2-T148-HG1 :120@OE1,OE2 :93@HG1 out dist_M2-E175_M2-T148.dat \n"
## calc inter monomer distance using COMs of M1 and M2
#CMD="$CMD distance M1-M2-COM :6-75&!@H= :94-163&!@H= out dist_M1-M2_COM.dat \n"
## calc inter monomer distance using bottom of the helix
#CMD="$CMD distance M1-M2-L46 :46@N :134@N out dist_M1-M2_L46.dat \n"
#
## dihedral angles of E175
#CMD="$CMD multidihedral phi resrange 32-32 out M1_E175_phi.dat \n"
#CMD="$CMD multidihedral psi resrange 32-32 out M1_E175_psi.dat \n"
#CMD="$CMD multidihedral dihtype chi1:N:CA:CB:CG "
#CMD="$CMD               dihtype chi2:CA:CB:CG:CD "
#CMD="$CMD               dihtype chi3:CB:CG:CD:OE1 "
#CMD="$CMD               resrange 32-32"
#CMD="$CMD               out M1_E175_chi123.dat \n"
#CMD="$CMD multidihedral phi resrange 120-120 out M2_E175_phi.dat \n"
#CMD="$CMD multidihedral psi resrange 120-120 out M2_E175_psi.dat \n"
#CMD="$CMD multidihedral dihtype chi1:N:CA:CB:CG "
#CMD="$CMD               dihtype chi2:CA:CB:CG:CD "
#CMD="$CMD               dihtype chi3:CB:CG:CD:OE1 "
#CMD="$CMD               resrange 120-120"
#CMD="$CMD               out M2_E175_chi123.dat \n"

## loop all residues of a single monomer
#for I in {1..88} ; do
#    CMD="$CMD distance m1w184_m2_ca_${I} :${I}@CA :41@CA out m1w184_m2_ca_dmat.dat \n"
#    CMD="$CMD distance m2w184_m1_ca_${I} :$(($I + 88))@CA :129@CA out m2w184_m1_ca_dmat.dat \n"
#    CMD="$CMD distance m1w184_m2_cb_${I} :${I}@CB :41@CB out m1w184_m2_cb_dmat.dat \n"
#    CMD="$CMD distance m2w184_m1_cb_${I} :$(($I + 88))@CB :129@CB out m2w184_m1_cb_dmat.dat \n"
#done
#
## multi dihedral
#CMD="$CMD multidihedral phi psi chip resrange 1-176 out phi_psi.dat \n"
#CMD="$CMD multidihedral phi psi resrange 1-176 out phi_psi_chip.dat \n"
#CMD="$CMD multidihedral psi resrange 1-176 out dihedrals.dat \n"
#CMD="$CMD multidihedral dihtype chi1:N:CA:CB:CG "
#CMD="$CMD               dihtype chi2:CA:CB:CG:CD "
#CMD="$CMD               dihtype chi3:CB:CG:CD:OE1 "
#CMD="$CMD               resrange 1-176"
#CMD="$CMD               out dihedrals.dat \n"

# done
CMD="$CMD go \n"

echo -e "$CMD" | cpptraj

