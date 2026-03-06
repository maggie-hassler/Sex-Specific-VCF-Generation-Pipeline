#!/bin/bash
#SBATCH --job-name="SCC_WGS_flagstat"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/logs/slurm.%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/logs/slurm.%A_%a.err
#SBATCH --mem=16G
#SBATCH --time=0-08:00:00
#SBATCH --partition=general
#SBATCH --cpus-per-task=16
#SBATCH --array=0-84

# UPDATED A11 grch38 remap on 7/12/25
# COMMANDLINE samtools quickcheck -v *.dedup.bam

# exit on silent errors
set -euo pipefail 

# load samtools
module load samtools-1.21-gcc-12.1.0

# define paths 
IN_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/bam/wgs/grch38/wgs_scc_mapped"
OUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/grch38_bamstats"

# make sure output directory exists
mkdir -p "$OUT_DIR"

# define variables 
NAME=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))"p /data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/sample_names.txt)
TYPE="wgs"

# get stats 
samtools flagstat ${IN_DIR}/${NAME}.${TYPE}.*.dedup.bam > ${OUT_DIR}/${NAME}.samtools.txt

# COMMANDLINE multiqc *.samtools.txt