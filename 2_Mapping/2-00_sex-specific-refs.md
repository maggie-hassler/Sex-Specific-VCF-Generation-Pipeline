This markdown file documents the commands used to generate sex chromosome compliment GRCh38 references

It is based on the workflow linked below:  
INFO -> https://github.com/SexChrLab/SCC-alignment/blob/main/references/Instructions_SCC_references.md

The original copy of the reference used can be found here:
/data/CEM/shared/public_data/references/1000genomes_GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

Note: The output files are not included in shared directory and must be regenerated 

# 00 Copy reference to personal/lab directory 
```bash 
cp /data/CEM/shared/public_data/references/1000genomes_GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa ../your/directory
```

# 01 Check contig names 
```bash 
cd ../

grep ">" GRCh38_full_analysis_set_plus_decoy_hla.fa
```

# 02 Extract the X and Y from the reference 
```bash 
interactive 
module avail samtools
ml samtools-

samtools faidx GRCh38_full_analysis_set_plus_decoy_hla.fa chrY > GRCh38_Y_ONLY.fa
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla.fa chrX > GRCh38_X_ONLY.fa
```

# 03 Use lastz to identify the PARs by aligning the X and Y and outputting where there is 100% sequence identity of at least 50bp
```bash 
module avail lastz
ml lastz-

lastz GRCh38_X_ONLY.fa GRCh38_Y_ONLY.fa \
	--identity=100 \
	--exact=50 \
	--ambiguous=iupac \
	--notransition \
	--nogapped \
	--step=10 \
	--format=rdotplot > GRCh38_chrX_chrY_lastz_identity100_exact50_ambiguous_iupac_notransition_nogapped_step10.dotplot
```

# 04 Check length of Y chromosome 
```bash 
grep chrY GRCh38_full_analysis_set_plus_decoy_hla.fa.fai
# 57227415
```

# 05 Create text files with PARs and Y coordinates 
---
The locations for the PARs regions for GRCh38 can be found here: https://useast.ensembl.org/info/genome/genebuild/human_PARS.html

Create the following BED files (can be copy-pasted as-is if using GRCh38):

- **GRCh38_chrY.bed** (masks the entire Y):
```text
chrY	0	57227415
```
- **GRCh38_chrY_PARs.bed** (masks just the PARs on the Y):
```text
chrY	10000	2781479
chrY	56887902	57227415
```

# 06 Mask Y chromosome and Y PARs
```bash 
module avail bedtools
ml bedtools2-

# Mask only the PAR regions from chrY
bedtools maskfasta -fi GRCh38_Y_ONLY.fa -bed GRCh38_chrY_PARs.bed -fo GRCh38_chrY_YPARsMasked.fa

# Mask the entire chrY
bedtools maskfasta -fi GRCh38_Y_ONLY.fa -bed GRCh38_chrY.bed -fo GRCh38_chrY_YHardMasked.fa
```

# 07 Extract autosomes, M and X 
```bash 
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla.fa chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrM > GRCh38_chr1-22_chrX_chrM.fa
```

# 08 Merge back with autosomes to create the references 
```bash 
# YHardMasked
cat GRCh38_chr1-22_chrX_chrM.fa GRCh38_chrY_YHardMasked.fa > GRCh38_full_analysis_set_plus_decoy_hla_YHardMasked.fa

# YPARsMasked
cat GRCh38_chr1-22_chrX_chrM.fa GRCh38_chrY_YPARsMasked.fa > GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa
```

# 09 Index 
```bash 
# YHardMasked
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla_YHardMasked.fa

# YPARsMasked
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa
```

# 10 Create sequence dictionary (for GATK)
```bash 
ml mamba/latest
source activate gatk4_env # replace with your gatk or python env 

# GATK is written in java which has memory hardcoded in its interpreter (default is usually too low for FASTA files)
# FIX: Manually crank up the memory to 16g to run GATK on the command line with FASTA files 
export _JAVA_OPTIONS="-Xmx16g"

# YHardMasked
gatk CreateSequenceDictionary \
	-R GRCh38_full_analysis_set_plus_decoy_hla_YHardMasked.fa \
	-O GRCh38_full_analysis_set_plus_decoy_hla_YHardMasked.dict

# YPARsMasked
gatk CreateSequenceDictionary \
	-R GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa \
	-O GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.dict
```

# 11 BWA indexing (for bwa mem)
Note: indexing can run very slowly on large FASTA files, best to submit as a wrap (or batch)
```bash 
# YHardMasked
sbatch --job-name=bwa_index_yhard \
	--mail-user=YOURASURITE@asu.edu \
	--mail-type=ALL \
	--output=logs/bwa_index_yhard_%j.out \
	--error=logs/bwa_index_yhard_%j.err \
	--time=12:00:00 \
	--mem=32G \
	--cpus-per-task=1 \
	--wrap="module load bwa-0.7.17-gcc-12.1.0 && bwa index /path/to/your/scc-refs/GRCh38_full_analysis_set_plus_decoy_hla_YHardMasked.fa"

# YPARsMasked
sbatch --job-name=bwa_index_ypars \
	--mail-user=YOURASURITE@asu.edu \
	--mail-type=ALL \
	--output=logs/bwa_index_ypars_%j.out \
	--error=logs/bwa_index_ypars_%j.err \
	--time=12:00:00 \
	--mem=32G \
	--cpus-per-task=1 \
	--wrap="module load bwa-0.7.17-gcc-12.1.0 && bwa index /path/to/your/scc-refs/GRCh38_full_analysis_set_plus_decoy_hla_YPARsMasked.fa"
```
# Done! Yay! ��
Your SCC references are now ready 🧬
