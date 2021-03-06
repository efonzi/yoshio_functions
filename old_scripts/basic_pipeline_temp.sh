#!/bin/bash

BWAPATH=/Users/Eugenio/Desktop/NGScli/bwa-0.7.15
REFPATH=/Users/Eugenio/Desktop/NGScli/hg19
SAMPATH=/Users/Eugenio/Desktop/NGScli/alltools
BCFPATH=/Users/Eugenio/Desktop/NGScli/alltools
INPATH=$1
OUTPATH=$1


ls $1 | grep fastq.gz | grep botta2 > $1/fastqList
suffix="2"


k=0
while read line; do
    fastq+=($line)
    ((k++))
done < $1/fastqList


for (( c=0; c<$k; c++ )); do

    if (( $c % 2 == 0 )); then

    echo ${fastq[c]}
    echo ${fastq[c+1]}
    sampleName=$(echo ${fastq[c]} | cut -d '%' -f1)$suffix
    echo $sampleName
    $BWAPATH/bwa mem -t 4 $REFPATH/hg19.fa $INPATH/${fastq[c]} $INPATH/${fastq[c+1]} | $SAMPATH/samtools view -h | $SAMPATH/samtools view -b | $SAMPATH/samtools sort -o $OUTPATH/$sampleName.sort.bam

    $SAMPATH/samtools index $INPATH/$sampleName.sort.bam


    $SAMPATH/samtools mpileup -g -f $REFPATH/hg19.fa $INPATH/$sampleName.sort.bam > $OUTPATH/$sampleName.mpileup
    $BCFPATH/bcftools call -v -m -O v -o $OUTPATH/$sampleName.vcf $INPATH/$sampleName.mpileup

    fi

done
