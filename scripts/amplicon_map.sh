#!/bin/bash

MYLIB=$1
REF="ref/hambi23CorrectedReference.fa"

mkdir ../mapqc/${MYLIB}

# map to HAMBI 16S sequences
bbmap.sh ow=t int=f maxindel=20 minid=0.85 ambiguous=best \
ref=${REF} \
ehist=../mapqc/${MYLIB}/${MYLIB}.ehist \
qahist=../mapqc/${MYLIB}/${MYLIB}.qahist \
mhist=../mapqc/${MYLIB}/${MYLIB}.mhist \
idhist=../mapqc/${MYLIB}/${MYLIB}.idhist \
scafstats=../mapqc/${MYLIB}/${MYLIB}.scafstats \
statsfile=../mapqc/${MYLIB}/${MYLIB}.mapstats \
in=../processedreads/${MYLIB}.fastq.gz \
out=../mappedreads/${MYLIB}.sam

samtools stats ../mappedreads/${MYLIB}.sam > ../mapqc/${MYLIB}/${MYLIB}.samtoolsstats

# get number of reads mapped to each 16S sequence
pileup.sh ow=t in=../mappedreads/${MYLIB}.sam \
out=../mappedreads/${MYLIB}.coverage \
rpkm=../mappedreads/${MYLIB}.rpkm

# compress to bam
samtools view -bS ../mappedreads/${MYLIB}.sam > ../mappedreads/${MYLIB}.bam
rm ../mappedreads/${MYLIB}.sam
