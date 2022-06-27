# Introduction

Protocol for quality controlling MiSeq 16S 
amplicons and mapping to the HAMBI 16S database. 
Git repo can be cloned and used as template to perform 
other quality control and mapping tasks. Also see the 
github repo `hambiDemultiplex` for instructions on how to
demultiplex custom libraries prepared using the Adapterama II
protocol.

# Steps

## Get repository
`git clone https://github.com/slhogle/hambiAmplicon`

## Move sequence files
Move all raw sequence files to the `rawreads` directory.

## Quality control
edit the ampl_qc_tasklist to include your library names.

```
bash submit_greasy_ampl_qc.sh
```

## Read mapping
The quality control step should generate cleaned, overlapped
read pairs in the `processedreads` directory. Now these read pairs 
need to be mapped to the reference database in `/scripts/ref/hambi23CorrectedReference.fa`
Edit the ampl_map_tasklist to include your library names

```
bash submit_greasy_ampl_map.sh
```

## Double check
Check to see if the greasy steps produced files like `ampl_map_tasklist-undefined.rst`. 
Examine these files to see if any steps failed and why. 

## Summarizing reports

After ensuring all libraries have been processed, then proceed with submitting the script

```
bash qc_summarize.sh
```

which will generate multiqc summarized reports for subsequence inspection.
