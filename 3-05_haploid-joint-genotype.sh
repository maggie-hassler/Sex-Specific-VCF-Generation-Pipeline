#!/bin/bash
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%A_%a.out
#SBATCH -e logs/%A_%a.err
#SBATCH --mem=100G
#SBATCH --time=0-02:00:00
#SBATCH --partition=htc
#SBATCH --cpus-per-task=16

# Written on 2/26/26
# Usage: sbatch --job-name="chrY haploid genotyping" 3-02_gatk-genotype.sh chrY

# exit on silent errors
set -euo pipefail

# load environment
module load mamba/latest
source activate gatk4_env

# set paths and variables
CHROM=$1
REFERENCE=/data/CEM/wilsonlab/lab_generated/kenya/hassler/refs/grch38
INPUT=/data/CEM/wilsonlab/lab_generated/kenya/hassler/gvcf/wgs/grch38/chrY
OUTPUT=/data/CEM/wilsonlab/lab_generated/kenya/hassler/vcf/variant_only/merged

# ----- run genotyping ------ 

# for SNP genotyping
gatk GenotypeGVCFs \
	-R ${REFERENCE}/GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa \
	-V ${INPUT}/ALL.${CHROM}.g.vcf.gz \
	--sample-ploidy 1 \
	-O ${OUTPUT}/${CHROM}_wgs_turkana.haploid.vcf.gz

# MODIFY for all-sites genotyping
#gatk GenotypeGVCFs \
#	-R "$REF" \
#	-V gendb://${GENOMICSDB_DIR}/joint_${CHR}_db_${INTERVAL_SAFE} \
#	--include-non-variant-sites \
#	-L ${INTERVAL} \
#	-O ${OUTDIR}/${CHR}_joint_${INTERVAL_SAFE}.vcf.gz
