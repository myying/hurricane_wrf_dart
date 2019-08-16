#!/bin/bash

BASE_DIR=$WORK/hurricane_wrf_dart
SCRIPT_DIR=`pwd`
WORK_DIR=`pwd`/work
WRFDA_DIR=$WORK/code/WRFDAV3.9.1
DATE_START=2015102100
DATE_END=2015102300
ASSIM_INT_HOURS=6
OBS_WIN_HOURS=1

function advance_time {
  ccyymmdd=`echo $1 |cut -c1-8`
  hh=`echo $1 |cut -c9-10`
  inc=$2
  date -u -d $inc' hours '$ccyymmdd' '$hh':00' +%Y%m%d%H
}

function wrf_time_string {
  ccyy=`echo $1 |cut -c1-4`
  mm=`echo $1 |cut -c5-6`
  dd=`echo $1 |cut -c7-8`
  hh=`echo $1 |cut -c9-10`
  echo ${ccyy}-${mm}-${dd}_${hh}:00:00
}

mkdir -p $WORK_DIR
cd $WORK_DIR

#start processing data for each date
export DATE=$DATE_START
while [[ $DATE -le $DATE_END ]]; do
  echo $DATE
  ln -fs $WRFDA_DIR/var/obsproc/obsproc.exe .
  ln -fs $WRFDA_DIR/var/obsproc/obserr.txt .
  echo > obs.raw

  #NCAR_LITTLE_R
  cp $WORK/data/ncar_littler/${DATE:0:6}/obs.${DATE:0:10}.gz obs_littler.gz
  gunzip obs_littler.gz
  cat obs_littler >> obs.raw
  rm -f obs_littler

  DATE1=`advance_time $DATE -$OBS_WIN_HOURS`
  DATE2=`advance_time $DATE $OBS_WIN_HOURS`
  cat > script.sed << EOF
/time_analysis/c\
 time_analysis    = '`wrf_time_string $DATE`',
/time_window_min/c\
 time_window_min  = '`wrf_time_string $DATE1`',
/time_window_max/c\
 time_window_max  = '`wrf_time_string $DATE2`',
EOF
  sed -f script.sed $SCRIPT_DIR/namelist.obsproc.template > namelist.obsproc
  ln -fs $BASE_DIR/template/input.nml .
  ./obsproc.exe >& obsproc.log

  ln -fs obs_gts_`wrf_time_string $DATE`.3DVAR gts_obsout.dat
  $WORK/DART/observations/obs_converters/var/work/gts_to_dart >& gts_to_dart.log
  mv obs_seq.out $BASE_DIR/output/$DATE/.

  export DATE=`advance_time $DATE $ASSIM_INT_HOURS`
done

