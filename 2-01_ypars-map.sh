#!/bin/bash
#SBATCH --job-name="males-map-grch38"
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm_%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm_%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --time=1-00:00:00
#SBATCH --partition=general
#SBATCH --mem=200G
#SBATCH --cpus-per-task=32
#SBATCH --array=0-34

# NOTE modified for full WGS 7/9/25 using GRCh38 Y-PARs masked 

# exit on silent errors
set -euo pipefail

#load mamba
module load mamba/latest

# load bwa/latest and samtools/latest
module load bwa-0.7.17-gcc-12.1.0
module load samtools-1.21-gcc-12.1.0
module load picard-2.26.2-gcc-12.1.0

# define data directory & reference sequence # MODIFY 
DATA_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/fastq/wgs/trimmed_wgs"
OUTPUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/bam/wgs/grch38/wgs_scc_mapped"
REFS="/data/CEM/wilsonlab/lab_generated/kenya/hassler/refs/grch38/GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa" 
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" /data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/males.txt)
#SAMPLE="A100"
TYPE="wgs"
REF_NAME="ypars.grch38"

# make sure output directory exists
mkdir -p "$OUTPUT_DIR"

# map to reference (16t), convert sam to bam (4t), then sort(12t) # TODO check and change input file names 
bwa mem -t 16 \
	-R "@RG\tID:1\tSM:${SAMPLE}\tLB:lib1\tPU:unit1\tPL:ILLUMINA" \
	$REFS \
	${DATA_DIR}/"${SAMPLE}_wgs_trimmed_R1.fastq.gz" \
	${DATA_DIR}/"${SAMPLE}_wgs_trimmed_R2.fastq.gz" \
	| samtools view -Sb -@ 8 - \
	| samtools sort -@ 8 -o ${OUTPUT_DIR}/${SAMPLE}.${TYPE}.${REF_NAME}.sorted.bam
	#2> /data/CEM/wilsonlab/lab_generated/kenya/imsad/logs/${NAME}_samtools.err	#custom log per sample


# index sorted bams
samtools index ${OUTPUT_DIR}/${SAMPLE}.${TYPE}.${REF_NAME}.sorted.bam
# example output: A16.sorted.bam

# mark duplicates - #NOTE forgot this the first time but in the pipeline this'll be included
picard MarkDuplicates \
	I=${OUTPUT_DIR}/${SAMPLE}.${TYPE}.${REF_NAME}.sorted.bam \
	O=${OUTPUT_DIR}/${SAMPLE}.${TYPE}.${REF_NAME}.dedup.bam \
	M=/data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/${SAMPLE}_dedup_metrics.txt \
	REMOVE_DUPLICATES=true \
	VALIDATION_STRINGENCY=SILENT \
	CREATE_INDEX=true

# remove intermediate sorted BAM after MarkDuplicates completes
if [[ $? -eq 0 ]]; then
	rm ${OUTPUT_DIR}/${SAMPLE}.${TYPE}.${REF_NAME}.sorted.bam
	rm ${OUTPUT_DIR}/${SAMPLE}.${TYPE}.${REF_NAME}.sorted.bam.bai
else
	echo "Picard failed for ${SAMPLE}, not removing ${SAMPLE}.wes.sorted.bam" >&2
fi

# example output: A16.wgs.ypars.grch38.dedup.bam