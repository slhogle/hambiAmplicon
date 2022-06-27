#!/bin/bash

module load openjdk
module load greasy

mkdir ../mapqc
mkdir ../mappedreads

sbatch-greasy --tasks ampl_map_tasklist --cores 1 --time 15:00 --nodes 1 --account project_2006053
