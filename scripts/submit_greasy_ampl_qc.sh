#!/bin/bash

module load openjdk
module load vsearch
module load greasy

mkdir ../fastp_preprocess
mkdir ../processedreads
mkdir ../fastp_postprocess

sbatch-greasy --tasks ampl_qc_tasklist --cores 1 --time 15:00 --nodes 1 --account project_2006053
