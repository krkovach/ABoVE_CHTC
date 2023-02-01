### Bash workflow for processing HyTools BRDF and topographic corrections, followed by trait estimation for ABoVE data from the AVIRIS-NG sensor.

1. HyTools_CHTC.sub - Initial processing script for submitting jobs to the UW-CHTC cluster.
2. HyTools_CHTC.sh - Bash shell script for processing job on single node (also local machine).

**.sub** controls distribution of jobs using parameters from list */Tables/ABOVE_joblistfull.txt*.

**.sh** runs specific job on each node by lines pulled from locations and BRDF grouped according to file */Tables/ABOVE_Lines.txt*.  This file allows for the specification of different locations for both the **OBS_ORT** file and **image binary and .hdr files**.

#### Processing steps for *HyTools_CHTC.sh* are as follows:

1. Set environmental variables (specified from **.sub**).
2. Import and set Python environment (available [Here - add .gz to "Zips" folder](https://drive.google.com/file/d/1SA5sEl1XUSjpTKohVrjByJXYkqd5eNKi/view?usp=sharing)
3. Import and organize files necessary for processing.
4. Make folders and populate lists with necessary information from */Tables/ABOVE_Lines.txt* file.
5. Correction **OBS_ORT** rotation by creating newly corrected **OBS_ORT** file.
6. Carry out topogrpahic and grouped FlexBRDF correction.
7. Apply trait models to produce trait maps (NEON 2016-2018 models).
8. TAR and GZ all output files.
9. Cleanup temporary files.

