    parm ../1a43_dry.prmtop 
 trajin ../06_prod_dry_10i.nc 1 last 1 
 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [xtal] 
 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/2kod/std-prep/2kod_m01_solv.pdb :* name [nmr] 
 reference /ix/lchong/dty7/hiv1_capsid/we/unbinding/1a43/std-prep/1a43_solv3.pdb :* name [REF] 
 rms XTAL_RMS_FIT :6-75,94-163&!@H= ref [xtal] 
    rms Fit_M2_NMR :94-163&!@H= ref [nmr] 
 rms RMS_M1_NMR :6-75&!@H= ref [nmr] nofit mass time 1 out rms_m1_nmr.dat 
 rms RMS_H9M1_NMR :36-49&!@H= nofit ref [nmr] out rms_h9m1_nmr.dat mass time 1 
 rms Fit_M1_NMR :6-75&!@H= ref [nmr] 
 rms RMS_M2_NMR :94-163&!@H= ref [nmr] nofit mass time 1 out rms_m2_nmr.dat 
 rms RMS_H9M2_NMR :124-137&!@H= nofit ref [nmr] out rms_h9m2_nmr.dat mass time 1 
 rms RMS_Heavy_NMR :6-75,94-163&!@H= ref [nmr] mass time 1 out rms_heavy_nmr.dat 
 rms RMS_Backbone_NMR :6-75,94-163@CA,C,O,N ref [nmr] mass time 1 out rms_bb_nmr.dat 
 rms RMS_Dimer_Int_NMR :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [nmr] mass time 1 out rms_dimer_int_nmr.dat 
 rms RMS_Key_Int_NMR :38,41,42,126,129,130&!@H= ref [nmr] mass time 1 out rms_key_int_nmr.dat 
 rms Fit_M2_XTAL :94-163&!@H= ref [xtal] 
 rms RMS_M1_XTAL :6-75&!@H= ref [xtal] nofit mass time 1 out rms_m1_xtal.dat 
 rms RMS_H9M1_XTAL :36-49&!@H= nofit ref [xtal] out rms_h9m1_xtal.dat mass time 1 
 rms Fit_M1_XTAL :6-75&!@H= ref [xtal] 
 rms RMS_M2_XTAL :94-163&!@H= ref [xtal] nofit mass time 1 out rms_m2_xtal.dat 
 rms RMS_H9M2_XTAL :124-137&!@H= nofit ref [xtal] out rms_h9m2_xtal.dat mass time 1 
 rms RMS_Heavy_XTAL :6-75,94-163&!@H= ref [xtal] mass time 1 out rms_heavy_xtal.dat 
 rms RMS_Backbone_XTAL :6-75,94-163@CA,C,O,N ref [xtal] mass time 1 out rms_bb_xtal.dat 
 rms RMS_Dimer_Int_XTAL :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [xtal] mass time 1 out rms_dimer_int_xtal.dat 
 rms RMS_Key_Int_XTAL :38,41,42,126,129,130&!@H= ref [xtal] mass time 1 out rms_key_int_xtal.dat 

