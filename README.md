A step-by-step guide to running the WRF/DART system:
----------------------------------------------------------

Step 1: Compile WPS, WRF and WRFDA, DART/model/wrf/work

Step 2: Specify scripts/param.csh configuration

  template/input.nml, namelist.input, namelist.wps

Step 3: generate icbc

  grib data

    scripts/gen_retro_icbc.csh init_date end_date scripts/param.csh

Step 4: perturbation bank

    scripts/gen_pert_bank.csh init_date scripts/param.csh

Step 5: first cycle

    scripts/init_model_var.csh init_date scripts/param.csh

Step 6: prepare obs

  obs_seq.out files in output/dates/.
  
Step 7: start cycling DA with driver.csh

    scripts/driver.csh start_date end_date scripts/param.csh

----------------------------------------------------------
Adapting to other supercomputers:

  Change the account info, runtime cpu specifications in param.csh

  Change the type of commands: qsub, qstat, mpirun

  Change the job submission script headers in driver.csh, gen_pert_bank.csh, and init_ensemble_var.csh
