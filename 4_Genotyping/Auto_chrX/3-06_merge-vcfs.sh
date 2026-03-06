#!/bin/bash
#SBATCH --job-name="chrM-merge-all-sites"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH --time=0-06:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --partition=public

# exit on silent errors
set -euo pipefail

# load modules (in phx)
# ml bcftools-1.16-cw
#ml htslib-1.17-je

# load modules (in sol)
ml bcftools-1.14-gcc-11.2.0
ml htslib-1.21-gcc-12.1.0

# chromosome 
CHROM=chrM

# paths
IN_DIR=/data/CEM/wilsonlab/lab_generated/kenya/hassler/vcf/wgs/grch38/intervals_allsites/${CHROM}/
OUT_DIR=/data/CEM/wilsonlab/lab_generated/kenya/hassler/vcf/wgs/grch38/merged_allsites/
OUT_VCF=${OUT_DIR}/${CHROM}_wgs_turkana.vcf.gz

# create output dir if it doesn't exist
mkdir -p "$OUT_DIR"

# concatenate all interval VCFs in sorted order
bcftools concat -Oz -o "$OUT_VCF" \
	$(ls "$IN_DIR"/${CHROM}_joint_*.vcf.gz | sort -V)

# index the merged file
bcftools index -t "$OUT_VCF"
