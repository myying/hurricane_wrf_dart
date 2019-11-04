A step-by-step guide to running the WRF/DART system:
Yue (Michael) Ying 2019
----------------------------------------------------------

Step 1: Compile WPS, WRF and WRFDA, DART/models/wrf/work

Step 2: Specify scripts/param.csh configuration
  template/input.nml, namelist.input, namelist.wps

Step 3: generate icbc
  grib data
  scripts/gen_retro_icbc.csh init_date end_date scripts/param.csh

Step 4: perturbation bank
  scripts/gen_pert_bank.csh init_date scripts/param.csh

Step 5: first cycle
  scripts/init_model_var.csh

Step 6: prepare obs

Step 7: start cycling DA with driver.csh


----------------------------------------------------------
1. Specific types of observations
  NCAR_LITTLE_R formatted GTS data:
    Compile gts_to_dart in  DART/observations/obs_converter/var/3DVAR_OBSPROC/ (prepare dependent code from WRFDA)
                            DART/observations/obs_converter/var/work/quickbuild.csh
    obsproc.exe -> obs_gts_*3DVAR, link as gts_obsout.dat
    gts_to_dart -> obs_seq.out
    (you can write a shell script to batch process all the observation; mine is obs_process/run_obsproc.sh)

  Dropsonde observations:


  Airborne Doppler radar wind observations:
    converter:


2. Nested domain and preset moving nests
  


3. Adapting to other supercomputers:
  Change the account info, runtime cpu specifications in param.csh

  Change the type of commands: qsub, qstat, mpirun

  Change the job submission script headers in driver.csh, gen_pert_bank.csh, and init_ensemble_var.csh
