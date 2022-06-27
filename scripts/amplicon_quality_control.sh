#!/bin/bash

CONTAMS="/projappl/project_2005777/source/bbmap/v38.96/resources/adapters.fa"
MYLIB=$1

# get fastq stats of raw reads
fastp \
--in1 ../rawreads/${MYLIB}.fastq.gz --interleaved_in \
-j ../fastp_preprocess/${MYLIB}.json \
-h ../fastp_preprocess/${MYLIB}.html \
-R ${MYLIB} \
--dont_overwrite \
-w 1 \
-p \
-P 20 \
--disable_adapter_trimming \
--disable_trim_poly_g \
--disable_quality_filtering \
--disable_length_filtering

# clip any hanging bases (ie take a 301bp read to 300)
bbduk.sh ow=t ftm=5 \
in=../rawreads/${MYLIB}.fastq.gz \
out=../processedreads/${MYLIB}.00-ftm.fastq.gz

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.00-ftm.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# remove any leftover illumina adapters
bbduk.sh ow=t ref=${CONTAMS} \
ktrim=r k=23 mink=11 hdist=1 hdist2=1 tbo tpe \
in=../processedreads/${MYLIB}.tmp.fq.gz \
out=../processedreads/${MYLIB}.01-adaptertrim.fastq.gz

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.01-adaptertrim.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# filter any reads matching phiX spike in
bbduk.sh ow=t ref=phix k=31 hdist=1 \
in=../processedreads/${MYLIB}.tmp.fq.gz \
out=../processedreads/${MYLIB}.02-filtercontam.fastq.gz

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.02-filtercontam.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# quality-trim from the right to Q10 using the Phred algorithm.
bbduk.sh ow=t qtrim=r trimq=10 \
in=../processedreads/${MYLIB}.tmp.fq.gz \
out=../processedreads/${MYLIB}.03-qualitytrim.fastq.gz

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.03-qualitytrim.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# merge overlapping reads using bbmerge with default settings
bbmerge.sh ow=t \
in=../processedreads/${MYLIB}.tmp.fq.gz \
out=../processedreads/${MYLIB}.04-overlapped.fastq.gz

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.04-overlapped.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# map primer sequences and cut region between
msa.sh in=../processedreads/${MYLIB}.tmp.fq.gz \
out=../processedreads/${MYLIB}_F.sam \
literal=CCTACGGGAGGCAGCAG,CCTACGGGCGGCTGCAG,CCTACGGGGGGCAGCAG,CCTACGGGTGGCTGCAG,CCTACGGGAGGCTGCAG,CCTACGGGCGGCAGCAG,CCTACGGGGGGCTGCAG,CCTACGGGTGGCAGCAG \
rcomp=f \
cutoff=0.9 #ignore mappings less than 90% ID

msa.sh in=../processedreads/${MYLIB}.tmp.fq.gz \
out=../processedreads/${MYLIB}_R.sam \
literal=GGATTAGATACCCCAGTAGTC,GGATTAGATACCCTGGTAGTC,GGATTAGATACCCGTGTAGTC,GGATTAGATACCCCGGTAGTC,GGATTAGATACCCTTGTAGTC,GGATTAGATACCCGAGTAGTC,GGATTAGATACCCCTGTAGTC,GGATTAGATACCCTAGTAGTC,GGATTAGATACCCGGGTAGTC \
rcomp=f \
cutoff=0.9 #ignore mappings less than 90% ID

cutprimers.sh in=../processedreads/${MYLIB}.tmp.fq.gz \
sam1=../processedreads/${MYLIB}_F.sam \
sam2=../processedreads/${MYLIB}_R.sam \
out=../processedreads/${MYLIB}.05-primertrim.fastq.gz

rm ../processedreads/${MYLIB}_F.sam
rm ../processedreads/${MYLIB}_R.sam

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.05-primertrim.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# filtering based on max expected errors and length
vsearch --eeout --fastq_maxee 2 --fastq_maxlen 480 --fastq_minlen 360 \
--fastq_filter ../processedreads/${MYLIB}.tmp.fq.gz \
--fastqout_discarded ../processedreads/${MYLIB}.06-maxee-discarded.fastq \
--fastqout ../processedreads/${MYLIB}.06-maxee.fastq

gzip ../processedreads/${MYLIB}.06-maxee.fastq
gzip ../processedreads/${MYLIB}.06-maxee-discarded.fastq

cd ../processedreads; rm -f ${MYLIB}.tmp.fq.gz; ln -s ${MYLIB}.06-maxee.fastq.gz ${MYLIB}.tmp.fq.gz; cd ../scripts

# get fastq stats of cleaned reads
fastp -i ../processedreads/${MYLIB}.tmp.fq.gz \
-j ../fastp_postprocess/${MYLIB}.json \
-h ../fastp_postprocess/${MYLIB}.html \
-R ${MYLIB} \
--dont_overwrite \
-w 1 \
-p \
-P 20 \
--disable_adapter_trimming \
--disable_trim_poly_g \
--disable_quality_filtering \
--disable_length_filtering

# Cleanup
mv ../processedreads/${MYLIB}.06-maxee.fastq.gz ../processedreads/${MYLIB}.fastq.gz

rm -f ../processedreads/${MYLIB}.tmp.fq.gz
rm -f ../processedreads/${MYLIB}.00-ftm.fastq.gz
rm -f ../processedreads/${MYLIB}.01-adaptertrim.fastq.gz
rm -f ../processedreads/${MYLIB}.02-filtercontam.fastq.gz
rm -f ../processedreads/${MYLIB}.03-qualitytrim.fastq.gz
rm -f ../processedreads/${MYLIB}.04-overlapped.fastq.gz
rm -f ../processedreads/${MYLIB}.05-primertrim.fastq.gz
rm -f ../processedreads/${MYLIB}.06-maxee-discarded.fastq.gz
rm -f ../processedreads/${MYLIB}.06-maxee.fastq.gz
