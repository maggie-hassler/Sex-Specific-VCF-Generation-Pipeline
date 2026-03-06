#!/bin/bash
#SBATCH --job-name="wgs_trimming"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.err
#SBATCH --mem=64G
#SBATCH --time=0-02:00:00
#SBATCH --partition=general
#SBATCH --cpus-per-task=16
#SBATCH --array=0

# load mamba
module load mamba/latest

# activate the bbduk environment
source activate bbduk_env2

INPUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/fastq/wgs/fixed_wgs"
OUTPUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/testing_wgs/test_retrim_A100"
SAMPLES="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/one_sample_A100.txt"

# make sure output directory exists
mkdir -p "$OUTPUT_DIR"

# store current file inside a variable
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLES")
echo "Running BBDuk on $SAMPLE..."

# sanity check - make sure the script found the file
# check that input files exist
if [[ ! -f "${INPUT_DIR}/${SAMPLE}_R1_merged.fastq.gz" ]] || [[ ! -f "${INPUT_DIR}/${SAMPLE}_R2_merged.fastq.gz" ]]; then
	echo "Missing input FASTQ files for $SAMPLE, skipping..."
	exit 1
fi

# run bbduk
bbduk.sh \
		in1="${INPUT_DIR}/${SAMPLE}_R1_merged.fastq.gz" \
		in2="${INPUT_DIR}/${SAMPLE}_R2_merged.fastq.gz" \
		out1="${OUTPUT_DIR}/${SAMPLE}_wgs_trimmed_R1.fastq.gz" \
		out2="${OUTPUT_DIR}/${SAMPLE}_wgs_trimmed_R2.fastq.gz" \
		ref=/data/CEM/wilsonlab/lab_generated/kenya/hassler/adapters/adapters.fa \
		ktrim=r \
		k=21 \
		mink=11 \
		hdist=2 \
		qtrim=rl \
		trimq=15 \
		minlen=75 \
		maq=20 \
		threads=16
