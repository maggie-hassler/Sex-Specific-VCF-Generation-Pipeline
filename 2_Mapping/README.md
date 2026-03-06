Map trimmed reads to sex-specific reference builds, produce per-sample BAMs and depth summaries, visualize chromosome-wise coverage, and determine sample sex for downstream remapping of females to a no-Y reference.
Workflow overview:
  1. Generate sex-specific references:
      a. male reference: GRCh38 with PARs retained but Y optionally hard-masked (or alternate Y-masking as configured).
      b.female reference: GRCh38 with the entire Y chromosome masked.
  2. Map all samples to the PAR-masked GRCh38 (initial mapping).
  3. Compute per-chromosome depth/coverage with samtools depth / other tools.
  4. Run the R script to visualize depth and generate a coverage summary and classify samples as male or female based on coverage thresholds (documented criterion).
  5. Remap samples classified as female to the no-Y reference (to avoid Y mapping artefacts).
  6. Produce QC flagstat / mapping metrics for final BAMs.
