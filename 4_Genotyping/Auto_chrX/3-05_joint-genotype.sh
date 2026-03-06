#!/bin/bash
#SBATCH --job-name="genotype"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%A_%a.out
#SBATCH -e logs/%A_%a.err
#SBATCH --mem=200G
#SBATCH --time=0-18:00:00
#SBATCH --partition=public
#SBATCH --cpus-per-task=16
#SBATCH --array=0		# MODIFY array = num intervals for that chromosome 

# UPDATED 1/21/26 -- all sites 

# exit on silent errors
set -euo pipefail

# load environment
module load mamba/latest
source activate gatk4_env

# set variables
REF="/data/CEM/wilsonlab/lab_generated/kenya/hassler/refs/grch38/GRCh38_full_analysis_set_plus_decoy_hla.fa"
GENOMICSDB_DIR="/scratch/mhassle1/genomicsdb_workspace"

# grab list of chromosomes and set output directory # MODIFY 
CHR="chrM"
#OUTDIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/vcf/wgs/grch38/intervals_allsites/chr2"
OUTDIR="/data/stonelab/maggie/vcf/intervals_allsites/chrM"
INTERVAL_LIST="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/intervals/grch38/chrM_10Mb_wgs_intervals.list" 

# create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# get interval for this task # and then make sure it's directory name safe
INTERVAL=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$INTERVAL_LIST")
INTERVAL_SAFE=$(echo "$INTERVAL" | tr ':-' '_')

# run joint genotyping
gatk GenotypeGVCFs \
	-R "$REF" \
	-V gendb://${GENOMICSDB_DIR}/joint_${CHR}_db_${INTERVAL_SAFE} \
	--include-non-variant-sites \
	-L ${INTERVAL} \
	-O ${OUTDIR}/${CHR}_joint_${INTERVAL_SAFE}.vcf.gz

# REMEMBER index directory when done
# bcftools index *
