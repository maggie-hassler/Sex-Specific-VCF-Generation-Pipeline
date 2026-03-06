#!/bin/bash
#SBATCH --job-name="chrY haploid"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%A.out
#SBATCH -e logs/%A_%a.err
#SBATCH -q private
#SBATCH -p general
#SBATCH --mem=64G
#SBATCH --time=0-06:00:00
#SBATCH --cpus-per-task=16

# Written 7/12/25
# Usage:
#   sbatch variant-call.sh <chromosome>
# Example:
#   sbatch variant_call.sh chr1

# NOTE bcftools index output when done

# exit on silent errors
set -euo pipefail

# load modules
module load mamba/latest
source activate gatk4_env

# define chromosome
CHROM=$1 

# set paths and variables
REFERENCE=/data/CEM/wilsonlab/lab_generated/kenya/hassler/refs/grch38
GVCFS=/data/CEM/wilsonlab/lab_generated/kenya/hassler/gvcf/wgs/grch38/${CHROM}

gatk CombineGVCFs \
    -R ${REFERENCE}/GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa \
    -V ${GVCFS}/A100.chrY.g.vcf.gz \
    -V ${GVCFS}/A10.chrY.g.vcf.gz \
    -V ${GVCFS}/A18.chrY.g.vcf.gz \
    -V ${GVCFS}/A21.chrY.g.vcf.gz \
    -V ${GVCFS}/A22.chrY.g.vcf.gz \
    -V ${GVCFS}/A23.chrY.g.vcf.gz \
    -V ${GVCFS}/A24.chrY.g.vcf.gz \
    -V ${GVCFS}/A25.chrY.g.vcf.gz \
    -V ${GVCFS}/A32.chrY.g.vcf.gz \
    -V ${GVCFS}/A34.chrY.g.vcf.gz \
    -V ${GVCFS}/A36.chrY.g.vcf.gz \
    -V ${GVCFS}/A37.chrY.g.vcf.gz \
    -V ${GVCFS}/A38.chrY.g.vcf.gz \
    -V ${GVCFS}/A39.chrY.g.vcf.gz \
    -V ${GVCFS}/A40.chrY.g.vcf.gz \
    -V ${GVCFS}/A48.chrY.g.vcf.gz \
    -V ${GVCFS}/A51.chrY.g.vcf.gz \
    -V ${GVCFS}/A52.chrY.g.vcf.gz \
    -V ${GVCFS}/A57.chrY.g.vcf.gz \
    -V ${GVCFS}/A59.chrY.g.vcf.gz \
    -V ${GVCFS}/A60.chrY.g.vcf.gz \
    -V ${GVCFS}/A61.chrY.g.vcf.gz \
    -V ${GVCFS}/A62.chrY.g.vcf.gz \
    -V ${GVCFS}/A63.chrY.g.vcf.gz \
    -V ${GVCFS}/A67.chrY.g.vcf.gz \
    -V ${GVCFS}/A69.chrY.g.vcf.gz \
    -V ${GVCFS}/A72.chrY.g.vcf.gz \
    -V ${GVCFS}/A74.chrY.g.vcf.gz \
    -V ${GVCFS}/A79.chrY.g.vcf.gz \
    -V ${GVCFS}/A80.chrY.g.vcf.gz \
    -V ${GVCFS}/A81.chrY.g.vcf.gz \
    -V ${GVCFS}/A91.chrY.g.vcf.gz \
    -V ${GVCFS}/A93.chrY.g.vcf.gz \
    -V ${GVCFS}/A95.chrY.g.vcf.gz \
    -V ${GVCFS}/A98.chrY.g.vcf.gz \
    -O ${GVCFS}/ALL.chrY.g.vcf.gz