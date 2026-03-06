#!/bin/bash
#SBATCH --job-name="chrM-genomicsdb"	# MODIFY 
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err
#SBATCH --mem=32G
#SBATCH --time=2-00:00:00
#SBATCH --partition=public
#SBATCH --cpus-per-task=32
#SBATCH --array=0		# MODIFY to match number of intervals for each chromosome

# UPDATED 10/20/25 

# NOTE will take ≥13 hours for full directory to run (~ 20 minutes for two samples)

# exit on silent errors
set -euo pipefail

# load modules
module load mamba/latest
source activate gatk4_env

# set paths # MODIFY 
CHR="chrM"
INTERVAL_LIST="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/intervals/grch38/chrM_10Mb_wgs_intervals.list"
SAMPLE_MAP="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/grch38_sample_maps/chrM_sample_map.txt"

GENOMICSDB_DIR="/scratch/mhassle1/genomicsdb_workspace"
REF="/data/CEM/wilsonlab/lab_generated/kenya/hassler/refs/grch38/GRCh38_full_analysis_set_plus_decoy_hla.fa"

mkdir -p "$GENOMICSDB_DIR" 

INTERVAL=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$INTERVAL_LIST")
INTERVAL_SAFE=$(echo "$INTERVAL" | tr ':-' '_')

mkdir -p /scratch/mhassle1/genomicsdb_workspace/temp_dir/tmp_${CHR}_${INTERVAL_SAFE}

# run GATK GenomicsDBImport
gatk --java-options "-Xmx56G" GenomicsDBImport \
	-R "$REF" \
	--sample-name-map ${SAMPLE_MAP} \
	-L "$INTERVAL" \
	--genomicsdb-workspace-path ${GENOMICSDB_DIR}/joint_${CHR}_db_${INTERVAL_SAFE} \
	--interval-merging-rule OVERLAPPING_ONLY \
	--tmp-dir /scratch/mhassle1/genomicsdb_workspace/temp_dir/tmp_${CHR}_${INTERVAL_SAFE} \
	--reader-threads 32 
