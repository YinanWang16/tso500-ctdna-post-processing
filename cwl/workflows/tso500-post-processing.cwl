#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRquirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id sample_id
    type: string
  - id: raw_bam
    doc: |
      Raw alignment bam file
      Logs_Intermediates/AlignCollapseFusionCaller/{Sample_ID}/{Sample_ID}.bam
    type: File
  - id: tso_manifest_bed
    doc: |
      illumina/resources/TSTC500_manifest.bed
    type: File
  - id: vcf_files
    doc: |
      vcf files in Results/{Sample_ID} directory
      - {Sample_ID}_CopyNumberVariants.vcf
      - {Sample_ID}_MergedSmallVariants.genome.vcf
      - {Sample_ID}_MergedSmallVariants.vcf
    type: File[]
  - id: dragen_metrics_csv
    doc: |
      DRAGEN AlignCollapseFusionCaller metrics csv files
      Under "Logs_Intermediates/AlignCollapseFusionCaller", including:
      - {Sample_ID}.mapping_metrics.csv
      - {Sample_ID}.trimmer_metrics.csv
      - {Sample_ID}.umi_metrics.csv
      - {Sample_ID}.wgs_coverage_metrics.csv
      - {Sample_ID}.sv_metrics.csv
      - {Sample_ID}.time_metrics.csv
    type: File[]
  - id: tmb_trace_tsv
    doc: Results/{Sample_ID}/{Sample_ID}TMB_Trace.tsv
  - id: fragment_length_hist_csv
    doc: |
      Logs_Intermediates/AlignCollapseFusionCaller/{Sample_ID}/{Sample_ID}.fragment_length_hist.csv
    type: File
#  - id: backup_file_list
#    doc: | 
#      Files to backup, including
#      TSO500_Analysis_Output_Folder
#      ├── Logs_Intermediates
#      │  ├── AlignCollapseFusionCaller
#      │  │   └── {sample}
#      │  │      ├── evidence.{sample}.bam
#      │  │      ├── evidence.{sample}.bam.bai
#      │  │      ├── {sample}.bam
#      │  │      ├── {sample}.bam.bai
#      │  │      └── {sample}.bam.md5sum
#      │  ├── Msi
#      │  │   └── {sample}
#      │  │      └── {sample}.msi.json
#      │  ├── SampleAnalysisResults
#      │  │   └── {sample}
#      │  │      └── {sample}.SampleAnalysisResults.json
#      │  ├── Tmb
#      │  │   └── {sample}
#      │  │      └──{sample}.tmb.json
#      │  └── VariantCaller
#      │      └── {sample}
#      │         ├── {sample}.cleaned.stitched.bam
#      │         └── {sample}.cleaned.stitched.bam.bai
#      └── Results
#         ├── dsdm.json
#         ├── MetricsOutput.tsv
#         └── {sample}
#            ├── {sample}_Fusions.csv
#            └── {sample}_MergedSmallVariantsAnnotated.json.gz
outputs:
  - id: exon_coverage_qc
    type: File
    outputSource: mosdepth-thresholds-bed-to-coverage-QC-step/coverage_QC
  - id: json_gz_file_list
    type: File[]
    outputSource: gzip/gzipped_file
  - id: dragen_metrics_json
    type: File
    outputSource: dragen-metrics-csv2json/ 

