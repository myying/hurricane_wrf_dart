#!/bin/csh
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$
###Cleaned up by Michael Ying 2019

set datea     = ${1}
set emember   = ${2}
set paramfile = ${3}
source $paramfile

set start_time = `date +%s`
echo "host is " `hostname`

mkdir -p ${RUN_DIR}
cd ${RUN_DIR}

${COPY} ${TEMPLATE_DIR}/input.nml input.nml
sleep 10
set gdate = (`echo $datea 0 -g | ${DART_DIR}/models/wrf/work/advance_time`)
set gdatef = (`echo $datea $ASSIM_INT_HOURS -g | ${DART_DIR}/models/wrf/work/advance_time`)
set yyyy  = `echo $datea | cut -b1-4`
set mm    = `echo $datea | cut -b5-6`
set dd    = `echo $datea | cut -b7-8`
set hh    = `echo $datea | cut -b9-10`
set nn    = "00"
set ss    = "00"

echo $start_time >! ${RUN_DIR}/start_member_${emember}

cd $RUN_DIR/advance_temp${emember}
set icnum = `echo $emember + 10000 | bc | cut -b2-5`
if ( -e $RUN_DIR/advance_temp${emember}/wrf.info ) then
  ${REMOVE} $RUN_DIR/advance_temp${emember}/wrf.info
endif
touch wrf.info
if ( $SUPER_PLATFORM == 'cheyenne' ) then
  cat >! $RUN_DIR/advance_temp${emember}/wrf.info << EOF
 ${gdatef[2]}  ${gdatef[1]}
 ${gdate[2]}   ${gdate[1]}
$yyyy $mm $dd $hh $nn $ss
           ${NUM_DOMAINS}
 mpirun ./wrf.exe
EOF
endif

cd $RUN_DIR
echo $emember                      >! ${RUN_DIR}/filter_control${icnum}
echo filter_restart_d01.${icnum}   >> ${RUN_DIR}/filter_control${icnum}
echo prior_d01.${icnum}            >> ${RUN_DIR}/filter_control${icnum}

#  integrate the model forward in time
${COPY} ${TEMPLATE_DIR}/namelist.input ${RUN_DIR}/namelist.input
${SHELL_SCRIPTS_DIR}/new_advance_model.csh ${emember} 1 filter_control${icnum} $paramfile
${REMOVE} ${RUN_DIR}/filter_control${icnum}

# move the output to the appropriate directory
mkdir -p ${OUTPUT_DIR}/${datea}/PRIORS
mv $RUN_DIR/prior_d01.${icnum} ${OUTPUT_DIR}/${datea}/PRIORS/prior_d01.${icnum}

set end_time   = `date  +%s`
@ length_time  = $end_time - $start_time
echo "duration = $length_time"

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$
