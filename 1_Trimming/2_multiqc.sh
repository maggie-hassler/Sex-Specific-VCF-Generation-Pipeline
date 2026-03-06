#!/bin/bash
#SBATCH --job-name="wgs_gvcf_multiqc"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.err
#SBATCH -n 1
#SBATCH --time=0-02:00:00
#SBATCH --partition=htc
#SBATCH --mem=64G

# define variables 
JOB_NAME="wgs_gvcf_stats"
DIRECTORIES="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/chr_dirs.txt"
CHROM=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))"p "$DIRECTORIES")
DATA_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/vcf_stats/${CHROM}_vcf_stats"
OUTPUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/vcf_stats/${CHROM}_vcf_stats"

# make sure output directory exists 
mkdir -p "$OUTPUT_DIR"

# load modules 
module load mamba/latest
source activate multiqc_env2 

# run multiqc
multiqc "$DATA_DIR" -o "$OUTPUT_DIR"

# rename report 
mv "$OUTPUT_DIR/multiqc_report.html" "$OUTPUT_DIR/${JOB_NAME}.multiqc.html"
