#!/usr/bin/env bash

module load multiqc

mkdir ../multiqc

# run on the amplicon qc data
cd ../fastp_preprocess
rename 's/.html/.fastp.html/' *
rename 's/.json/.fastp.json/' *
multiqc -n fastp_preprocess --no-data-dir .
mv fastp_preprocess.html ../multiqc

cd ../fastp_postprocess
rename 's/.html/.fastp.html/' *
rename 's/.json/.fastp.json/' *
multiqc -n fastp_postprocess --no-data-dir .
mv fastp_postprocess.html ../multiqc

cd ..
tar czf fastp_preprocess.tar.gz fastp_preprocess
tar czf fastp_postprocess.tar.gz fastp_postprocess
rm -rf fastp_preprocess fastp_postprocess

# run on the amplicon mapping data
cd mapqc

printf '%s\n' * > files.txt
split -l 40 files.txt
ls xa* > dirs.txt
cat dirs.txt | while read id; do mkdir mapqc_${id}; done
cat dirs.txt | while read id; do cat ${id} | parallel mv {} mapqc_${id}; done

rm -rf xa*

cat dirs.txt | while read id; do multiqc -n mapqc_${id} --no-data-dir mapqc_${id}; done
cat dirs.txt | while read id; do tar -czf mapqc_${id}.tar.gz mapqc_${id}; done
cat dirs.txt | while read id; do rm -rf mapqc_${id}; done

mv *.html ../multiqc

cd ..
tar czf mapqc.tar.gz mapqc
rm -rf mapqc
