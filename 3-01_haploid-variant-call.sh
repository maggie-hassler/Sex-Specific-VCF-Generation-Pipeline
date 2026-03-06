#!/bin/bash
#SBATCH --job-name="chrY haploid"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%A_%a.out
#SBATCH -e logs/%A_%a.err
#SBATCH -q private
#SBATCH -p general
#SBATCH --mem=64G
#SBATCH --time=0-01:00:00
#SBATCH --cpus-per-task=16
#SBATCH --array=0-34 

# Usage:
#   sbatch 3-01_haploid-variant-call.sh <chrom>
# Example:
#   sbatch 3-01_haploid-variant_call.sh chrY

# exit on silent errors
set -euo pipefail

# load modules
module load mamba/latest
source activate gatk4_env

CHROM=$1

# define variables
SAMPLES="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/males.txt"
REF="/data/CEM/wilsonlab/lab_generated/kenya/hassler/refs/grch38/GRCh38_full_analysis_set_plus_decoy_hla.fa"

# parallelize across store current sample name inside variable
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLES")

# define input and output
BAM=/data/CEM/wilsonlab/lab_generated/kenya/hassler/bam/wgs/grch38/wgs_scc_mapped/${SAMPLE}.wgs.ypars.grch38.dedup.bam
OUTDIR=/data/CEM/wilsonlab/lab_generated/kenya/hassler/gvcf/wgs/grch38/${CHROM}_allsites
mkdir -p ${OUTDIR}
OUTFILE=${OUTDIR}/${SAMPLE}.${CHROM}.g.vcf.gz

# run gatk # MODIFY for all sites
gatk HaplotypeCaller \
	-R $REF \
	-I $BAM \
	-O $OUTFILE \
	-ERC GVCF \
	-L $CHROM \
	--sample-ploidy 1 \
	-all-sites \
	--native-pair-hmm-threads $SLURM_CPUS_PER_TASK

# example output: A100.chr2.g.vcf.gz
