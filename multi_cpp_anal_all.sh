#!/bin/bash
# script to run cpptraj analysis for multiple directories

DO_PARALLEL="mpirun -np 8"
CPPTRAJ=cpptraj.MPI

PDBS=(2kod 1a43)
TYPES=(std-prep)

TIME=1us

for TYPE in ${TYPES[@]} ; do
    for PDB in ${PDBS[@]} ; do
        cd $PDB/$TYPE
        echo -e "\nSTARTING ${PDB^^} RUN for ${TYPE}"
    
        mkdir 1us
        cd 1us

        echo "RUNNING ${PDB^^} ${TIME}..."        

        # interval for all trajectories loaded    
        INTV=1

        if [ $PDB = "2kod" ] ; then
            C0="    parm ../${PDB}_m01_dry.prmtop \n"
        elif [ $PDB = "1a43" ] ; then
            C0="    parm ../${PDB}_dry.prmtop \n"
        fi
        # load traj files
        C0="$C0 trajin ../06_prod_dry_10i.nc 1 last $INTV \n"
        
        # get both refs but only fit to one
        if [ $PDB = "2kod" ] ; then
            C0="$C0 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [xtal] \n"
            C0="$C0 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [nmr] \n"
            C0="$C0 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [REF] \n"
            C0="$C0 rms NMR_RMS_FIT :6-75,94-163&!@H= ref [nmr] \n"
        elif [ $PDB = "1a43" ] ; then
            C0="$C0 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [xtal] \n"
            C0="$C0 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [nmr] \n"
            C0="$C0 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [REF] \n"
            C0="$C0 rms XTAL_RMS_FIT :6-75,94-163&!@H= ref [xtal] \n"
        fi

        # calc dimer C2 helical angle using vectors
        C1="    vector M1 :1-75@CA,C,O,N :39@CA,C,O,N \n"
        C1="$C1 vector M2 :89-163@CA,C,O,N :127@CA,C,O,N \n"
        C1="$C1 vectormath vec1 M1 vec2 M2 out 1-75_39_c2_angle.dat name C2_Angle dotangle \n"
        # calc dimer C2 helical angle using a 3 point angle definition
        # using backbone N of: T186 M1 --- M1 and M2 V181 --- T186 M2
        C1="$C1 angle helix_angle :43@N :38,126@N :131@N out angle_3pt.dat mass \n"
        # calc distance between (COM) both O eps of E175 and H eps 1 of W184
        C1="$C1 distance M1-E175-Oe_M2-W184-He1 :32@OE1,OE2 :129@HE1 out dist_M1-E175_M2-W184.dat \n"
        C1="$C1 distance M2-E175-Oe_M1-W184-He1 :120@OE1,OE2 :41@HE1 out dist_M2-E175_M1-W184.dat \n"
        # calc distance between (COM) both O eps of E175 and HG1 of T148
        C1="$C1 distance M1-E175-Oe_M1-T148-HG1 :32@OE1,OE2 :5@HG1 out dist_M1-E175_M1-T148.dat \n"
        C1="$C1 distance M2-E175-Oe_M2-T148-HG1 :120@OE1,OE2 :93@HG1 out dist_M2-E175_M2-T148.dat \n"
        # calc inter monomer distance using COMs of M1 and M2
        C1="$C1 distance M1-M2-COM :6-75&!@H= :94-163&!@H= out dist_M1-M2_COM.dat \n"
        # calc inter monomer distance using bottom of the helix
        C1="$C1 distance M1-M2-L46 :46@N :134@N out dist_M1-M2_L46.dat \n"
        # RoG
        C1="$C1 radgyr rog-cut-nomw :6-75,94-163&!@H= out rog.dat \n"
        C1="$C1 radgyr rog-all-mw :1-176 out rog-all-mw.dat mass \n"
        # calc both ref RMSD, do this last to not fit incorrectly
        #C1="$C1 rms XREF_RMS :6-75,94-163&!@H= out XTAL_REF_RMS_Heavy.dat ref [xtal] mass \n"
        #C1="$C1 rms NMR_RMS :6-75,94-163&!@H= out NMR_REF_RMS_Heavy.dat ref [nmr] mass \n"
        C1="$C1 run \n"
        C1="$C1 quit"
    
        # TODO: sasa?, nc but atomic level <4.5A

        echo -e "$C0$C1" > C0C1.cpp
        $DO_PARALLEL $CPPTRAJ -i C0C1.cpp > C0C1.out

        #####################################################

        # PCA analysis: first make sure rms fit in C0
        MASK=":6-75,94-163&!@H="
        # calc covariance matrix
        C2="    matrix covar name covar $MASK \n"
        # create a crd set to be consistent in later calcs
        C2="$C2 createcrd CRD \n"
        C2="$C2 run \n"
        # diagonalize the covar matrix to find the 1st 3 eigenvectors (PCs)
        C2="$C2 runanalysis diagmatrix covar "
        C2="$C2             vecs 3 name myEvecs "
        C2="$C2             nmwiz nmwizvecs 3 nmwizfile pca.nmd " 
        C2="$C2             nmwizmask $MASK \n"
        # project the eigenvectors onto the trajectory to get per frame output
        C2="$C2 crdaction CRD projection PROJECTION evecs myEvecs "
        C2="$C2           beg 1 end 3 $MASK out pca-proj.dat \n"
        C2="$C2 run \n"
        C2="$C2 quit"
    
        #echo -e "$C0$C2" > C0C2.cpp
        #$DO_PARALLEL $CPPTRAJ -i C0C2.cpp > C0C2.out

        #####################################################

        # per residue rmsd
        C3="    rms rms_non_term :6-75,94-163&!@H= ref [REF] mass"
        C3="$C3     perres    perresmask &!@CA,C,O,N"
        C3="$C3     perresout rmsd_perres.dat"
        C3="$C3     perresavg rmsd_perres_avg.dat \n"

        # per residue DSSP
        C3="$C3 secstruct ss :*"
        C3="$C3           out       ss.dat"
        C3="$C3           sumout    ss_sum.dat"
        C3="$C3           assignout ss_assign.dat \n"

        # calc torsions of all residues
        C3="$C3 multidihedral phi resrange 1-176 out dihedral_phi_1-176.dat \n"
        C3="$C3 multidihedral psi resrange 1-176 out dihedral_psi_1-176.dat \n"
        C3="$C3 multidihedral chip resrange 1-176 out dihedral_chip_1-176.dat \n"

        # calc E175 chi angles
        C3="    multidihedral dihtype chi1:N:CA:CB:CG "
        C3="$C3               dihtype chi2:CA:CB:CG:CD "
        C3="$C3               dihtype chi3:CB:CG:CD:OE1 "
        C3="$C3               resrange 32-32"
        C3="$C3               out dihedral_chi123_E175_M1.dat \n"
        C3="$C3 multidihedral dihtype chi1:N:CA:CB:CG "
        C3="$C3               dihtype chi2:CA:CB:CG:CD "
        C3="$C3               dihtype chi3:CB:CG:CD:OE1 "
        C3="$C3               resrange 120-120"
        C3="$C3               out dihedral_chi123_E175_M2.dat \n"

        #echo -e "$C0$C3" > C0C3.cpp
        #$DO_PARALLEL $CPPTRAJ -i C0C3.cpp > C0C3.out

        #####################################################

        # NMR ref rms calcs
        C4="    rms Fit_M2_NMR :94-163&!@H= ref [nmr] \n"
        C4="$C4 rms RMS_M1_NMR :6-75&!@H= ref [nmr] nofit mass time 1 out rms_m1_nmr.dat \n"
        C4="$C4 rms RMS_H9M1_NMR :36-49&!@H= nofit ref [nmr] out rms_h9m1_nmr.dat mass time 1 \n"
        
        C4="$C4 rms Fit_M1_NMR :6-75&!@H= ref [nmr] \n"
        C4="$C4 rms RMS_M2_NMR :94-163&!@H= ref [nmr] nofit mass time 1 out rms_m2_nmr.dat \n"
        C4="$C4 rms RMS_H9M2_NMR :124-137&!@H= nofit ref [nmr] out rms_h9m2_nmr.dat mass time 1 \n"
        
        C4="$C4 rms RMS_Heavy_NMR :6-75,94-163&!@H= ref [nmr] mass time 1 out rms_heavy_nmr.dat \n"
        C4="$C4 rms RMS_Backbone_NMR :6-75,94-163@CA,C,O,N ref [nmr] mass time 1 out rms_bb_nmr.dat \n"
        C4="$C4 rms RMS_Dimer_Int_NMR :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [nmr] mass time 1 out rms_dimer_int_nmr.dat \n"
        C4="$C4 rms RMS_Key_Int_NMR :38,41,42,126,129,130&!@H= ref [nmr] mass time 1 out rms_key_int_nmr.dat \n"
        
        # XTAL ref rms calcs
        C4="$C4 rms Fit_M2_XTAL :94-163&!@H= ref [xtal] \n"
        C4="$C4 rms RMS_M1_XTAL :6-75&!@H= ref [xtal] nofit mass time 1 out rms_m1_xtal.dat \n"
        C4="$C4 rms RMS_H9M1_XTAL :36-49&!@H= nofit ref [xtal] out rms_h9m1_xtal.dat mass time 1 \n"
        
        C4="$C4 rms Fit_M1_XTAL :6-75&!@H= ref [xtal] \n"
        C4="$C4 rms RMS_M2_XTAL :94-163&!@H= ref [xtal] nofit mass time 1 out rms_m2_xtal.dat \n"
        C4="$C4 rms RMS_H9M2_XTAL :124-137&!@H= nofit ref [xtal] out rms_h9m2_xtal.dat mass time 1 \n"
        
        C4="$C4 rms RMS_Heavy_XTAL :6-75,94-163&!@H= ref [xtal] mass time 1 out rms_heavy_xtal.dat \n"
        C4="$C4 rms RMS_Backbone_XTAL :6-75,94-163@CA,C,O,N ref [xtal] mass time 1 out rms_bb_xtal.dat \n"
        C4="$C4 rms RMS_Dimer_Int_XTAL :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [xtal] mass time 1 out rms_dimer_int_xtal.dat \n"
        C4="$C4 rms RMS_Key_Int_XTAL :38,41,42,126,129,130&!@H= ref [xtal] mass time 1 out rms_key_int_xtal.dat \n"


        echo -e "$C0$C4" > C0C4.cpp
        $DO_PARALLEL $CPPTRAJ -i C0C4.cpp > C0C4.out

        #####################################################
        echo "    FINISHED ${PDB^^} ${TIME}"
        
        # go back from the time dir (e.g. 1us)
        cd ..

        # go back to before type and pdb dirs
        cd ../../
    done
done
