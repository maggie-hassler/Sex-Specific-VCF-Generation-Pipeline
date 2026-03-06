#!/bin/sh
#SBATCH --job-name="wgs_vcf_stats"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/slurm.%A_%a.out
#SBATCH -e logs/slurm.%A_%a.err
#SBATCH -n 1
#SBATCH --time=0-04:00:00
#SBATCH --partition=htc
#SBATCH --mem=16G
#SBATCH --array=0-23

# UPDATED 8/26/25 for grch38 wgs vcf stats

# exit on silent errors
set -euo pipefail

# load bcftools
module load bcftools-1.14-gcc-11.2.0

LIST="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/chr_dirs.txt"
CHROM=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))"p "$LIST")

VCF="/data/CEM/wilsonlab/lab_generated/kenya/hassler/vcf/wgs/grch38/merged/${CHROM}_wgs_turkana.vcf.gz"
OUTDIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/grch38_vcf_stats"
mkdir -p "$OUTDIR"

bcftools stats "$VCF" > "$OUTDIR/${CHROM}.vcf.stats"

# REMEMBER to run multiqc on output 