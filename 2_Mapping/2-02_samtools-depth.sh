#!/bin/bash
#SBATCH --job-name="samtool_depth_WGS"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH -o /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.out
#SBATCH -e /data/CEM/wilsonlab/lab_generated/kenya/hassler/logs/slurm.%A_%a.err
#SBATCH --mem=64G
#SBATCH --time=0-12:00:00
#SBATCH --partition=general
#SBATCH --cpus-per-task=16
#SBATCH --array=0-84

# NOTE modified on 5/15/25 for full WGS bam directory 

# load modules
module load samtools-1.21-gcc-12.1.0

# define variables
DATA_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/bam/wgs/wgs_ypars"
OUTPUT_DIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/sex_qc/wgs"
SAMPLES="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/sample_names.txt"

# chromosomes
Y_CHROM="CP086569.2"
X_CHROM="CP068255.2"

# make sure output directory exist 
mkdir -p "$OUTPUT_DIR"

# store current file inside a variable 
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLES") 
BAM="${DATA_DIR}/${SAMPLE}.wgs.ypars.dedup.bam"

# make sure BAM exists; if not then bounce 
if [[ ! -f "$BAM" ]]; then
	echo "Missing BAM: $BAM"
	exit 1
fi 

# get mean sex chromosome depth
Y_DEPTH=$(samtools depth -a -r "$Y_CHROM" "$BAM" | awk '{sum+=$3} END {if (NR>0) print sum/NR; else print 0}')
X_DEPTH=$(samtools depth -a -r "$X_CHROM" "$BAM" | awk '{sum+=$3} END {if (NR>0) print sum/NR; else print 0}')

# append to CSV files 
echo "$SAMPLE,$Y_DEPTH" >> "${OUTPUT_DIR}/${SAMPLE}.y_depth.tmp"
echo "$SAMPLE,$X_DEPTH" >> "${OUTPUT_DIR}/${SAMPLE}.x_depth.tmp"

# NOTE RUN THIS ON THE OUTPUT DIRECTORY ONCE JOB FINISHES:

# cat /data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/sex_qc/*.y_depth.tmp > /data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/sex_qc/y_depth.csv
# cat /data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/sex_qc/*.x_depth.tmp > /data/CEM/wilsonlab/lab_generated/kenya/hassler/quality_control/sex_qc/x_depth.csv
