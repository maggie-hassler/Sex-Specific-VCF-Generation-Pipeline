#!/bin/sh
#SBATCH --job-name="trimmed_wgs_fastqc"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.err
#SBATCH -n 1
#SBATCH --time=0-02:00:00
#SBATCH --partition=htc
#SBATCH --mem=16G
#SBATCH --array=0

# define variables 
DATA_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/testing_wgs/test_retrim_A100"
OUTPUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/testing_wgs/test_retrim_A100"
SAMPLES="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/one_sample_A100.txt"

# make sure output directory exists 
mkdir -p "$OUTPUT_DIR"

# load modules 
module load fastqc-0.12.1-gcc-11.2.0

# store current file inside a variable 
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))"p "$SAMPLES")

# define input files
R1_FILE="${DATA_DIR}/${SAMPLE}_wgs_trimmed_R1.fastq.gz"
R2_FILE="${DATA_DIR}/${SAMPLE}_wgs_trimmed_R2.fastq.gz"

# run fastqc if files exist
if [[ -e "$R1_FILE" && -e "$R2_FILE" ]]; then
	echo "Running FastQC on $SAMPLE..."
	fastqc "$R1_FILE" "$R2_FILE" -o "$OUTPUT_DIR"
else
	echo "Missing FASTQ files for $SAMPLE"
	exit 1
fi

echo "FastQC analysis completed for $SAMPLE."