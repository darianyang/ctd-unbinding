    parm ../1a43_dry.prmtop 
 trajin ../06_prod_dry_10i.nc 1 last 1 
 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [xtal] 
 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [nmr] 
 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [REF] 
 rms XTAL_RMS_FIT :6-75,94-163&!@H= ref [xtal] 
    vector M1 :1-75@CA,C,O,N :39@CA,C,O,N 
 vector M2 :89-163@CA,C,O,N :127@CA,C,O,N 
 vectormath vec1 M1 vec2 M2 out 1-75_39_c2_angle.dat name C2_Angle dotangle 
 angle helix_angle :43@N :38,126@N :131@N out angle_3pt.dat mass 
 distance M1-E175-Oe_M2-W184-He1 :32@OE1,OE2 :129@HE1 out dist_M1-E175_M2-W184.dat 
 distance M2-E175-Oe_M1-W184-He1 :120@OE1,OE2 :41@HE1 out dist_M2-E175_M1-W184.dat 
 distance M1-E175-Oe_M1-T148-HG1 :32@OE1,OE2 :5@HG1 out dist_M1-E175_M1-T148.dat 
 distance M2-E175-Oe_M2-T148-HG1 :120@OE1,OE2 :93@HG1 out dist_M2-E175_M2-T148.dat 
 distance M1-M2-COM :6-75&!@H= :94-163&!@H= out dist_M1-M2_COM.dat 
 distance M1-M2-L46 :46@N :134@N out dist_M1-M2_L46.dat 
 radgyr rog-cut-nomw :6-75,94-163&!@H= out rog.dat 
 radgyr rog-all-mw :1-176 out rog-all-mw.dat mass 
 run 
 quit
