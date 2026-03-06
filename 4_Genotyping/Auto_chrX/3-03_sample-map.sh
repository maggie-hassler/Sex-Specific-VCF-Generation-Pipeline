#!/bin/bash
#SBATCH --job-name="genomicsdb-sample-map"
#SBATCH --mail-user=mhassle1@asu.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/slurm.%j.out
#SBATCH -e logs/slurm.%j.out
#SBATCH -n 1
#SBATCH --time=0-00:10:00
#SBATCH --partition=htc
#SBATCH --mem=64G

# UPDATED 7/15/25 for GRCh38 

# exit on silent errors
set -euo pipefail

GVCF_BASE="/data/CEM/wilsonlab/lab_generated/kenya/hassler/gvcf/wgs/grch38"
OUTDIR="/data/CEM/wilsonlab/lab_generated/kenya/hassler/scripts/manifest/grch38_sample_maps"
mkdir -p "${OUTDIR}"

# loop over chromosome directories like chr1/, chr2/, ..., x/, y/
for CHR_DIR in "${GVCF_BASE}"/chr*/; do
	CHR=$(basename "$CHR_DIR")  # e.g. chr10
	OUTMAP="${OUTDIR}/${CHR}_sample_map.txt"

	echo "Creating sample map for $CHR → $OUTMAP"
	> "$OUTMAP"

	for FILE in "$CHR_DIR"/*.g.vcf.gz; do
		[[ -f "$FILE" ]] || continue  # skip if no matches
		SAMPLE=$(basename "$FILE" | cut -d. -f1)
		echo -e "${SAMPLE}\t${FILE}" >> "$OUTMAP"
	done
done

echo "All sample maps generated in $OUTDIR"
