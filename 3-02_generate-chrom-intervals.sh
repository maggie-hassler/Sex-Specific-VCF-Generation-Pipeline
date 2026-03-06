#!/bin/bash
#SBATCH --job-name="intervals"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/logs/%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/logs/%A_%a.err
#SBATCH --mem=16G
#SBATCH --time=0-00:10:00
#SBATCH --partition=general
#SBATCH --cpus-per-task=16

# UPDATED for chromosomes on 7/15/25

# INFO -> chrom lengths for t2t found here: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009914755.1/
# INFO -> chrom lengths for GRCh38 found here: https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh38 (GRCh38)

# define variables 
#CONTIG="CP086569.2"
CHROM="chr7"
LENGTH="159345973"

STEP=10000000

# direct output 
OUTDIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/intervals/grch38"
mkdir -p ${OUTDIR}

# start for loop
# NOTE for ((initialization; condition; step))
for ((start=1; start<=$LENGTH; start+=$STEP)); do
	end=$((start + STEP - 1))
	if [ $end -gt $LENGTH ]; then
		end=$LENGTH
	fi
	echo "${CHROM}:${start}-${end}"
done > ${OUTDIR}/${CHROM}_10Mb_wgs_intervals.list
