#!/bin/bash

WEST_SIM_ROOT=$PWD

mkdir test_out
 

COMMAND="         parm $WEST_SIM_ROOT/common_files/m01_2kod_12A.prmtop\n" 
COMMAND="$COMMAND trajin bstates/06_prod.rst 1 last 10 \n"
COMMAND="$COMMAND reference $WEST_SIM_ROOT/reference/m01_2kod_12A.pdb [st0] \n"
COMMAND="$COMMAND autoimage \n"
COMMAND="$COMMAND rms fit :6-75,94-163@CA,C,O,N \n"
COMMAND="$COMMAND rms RMS_Heavy :6-75,94-163&!@H= ref [st0] mass time 10 out test_out/RMS_Heavy.dat \n"
COMMAND="$COMMAND rms RMS_Backbone :6-75,94-163@CA,C,O,N ref [st0] mass time 10 out test_out/RMS_Backbone.dat \n"
COMMAND="$COMMAND rms RMS_Dimer_Int :7,8,34,35,37,38,41,42,45,46,49,95,96,122,123,125,126,129,130,133,134,137&!@H= ref [st0] mass time 10 out test_out/RMS_Dimer_Int.dat\n"
COMMAND="$COMMAND radgyr RoG :1-176 out test_out/ROG.dat mass nomax \n"
COMMAND="$COMMAND surf Mono1_SASA :1-88 out test_out/Mono1_SASA.dat \n"
COMMAND="$COMMAND surf Mono2_SASA :89-176 out test_out/Mono2_SASA.dat \n"
COMMAND="$COMMAND surf Total_SASA :1-176 out test_out/Total_SASA.dat \n"
COMMAND="$COMMAND secstruct Secondary_Struct out test_out/Secondary_Struct.dat :1-176 \n"
COMMAND="$COMMAND nativecontacts name Num_Inter_Contacts :1-88&!@H= :89-176&!@H= byresidue distance 4.5 out test_out/Num_Inter_Contacts.dat ref [st0] \n"
COMMAND="$COMMAND nativecontacts name Num_Intra_Contacts :1-176&!@H= byresidue distance 4.5 out test_out/Num_Intra_Contacts.dat ref [st0] \n"
COMMAND="$COMMAND go\n"

echo -e "$COMMAND" | cpptraj.cuda


cat RMS_Heavy.dat | tail -n +2 | awk {'print $2'} > return.dat


