# tso500-ctdna-post-processing
This repo is to post-process TSO500 ctDNA output to
  * Upload Run data to PierianDx S3;
  * Hg19 to hg38 liftover;
  * Generate Failed_Exon_Coverage_QC.txt file for PierianDx CGW;
  * Combine per sample AlignCollapseFusionCaller metrics and convert to json;
  * Backup intermediate files to Results;
  * Compress and index VCFs (bgiz and tabix);
  * Split MetricsOutput.tsv to per sample file;
  * Convert tsv files to json.
