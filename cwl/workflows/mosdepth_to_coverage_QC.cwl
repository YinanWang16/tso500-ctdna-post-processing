#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

# Extensions
$namespaces:
  s: https://schema.org/

# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

# label/doc
id: make_coverage_QC
label: mosdepth_to_coverage_QC
doc: |
  Input is mosdepth output 'threshold.bed.gz'.
  Outputs are 'Failed_Exon_coverage_QC.txt' and 'target_region_coverage_metrics'.

# about the code
# s:dateCreated: 2021-05-30
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processing

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  bam_file:
    label: Sample_ID.bam
    doc: The path to the raw alignment bam file
    type: File
    secondaryFiles: .bai
  tso_manifest_bed:
    label: TST500C_manifest.bed
    doc: TSO manifest bed file
    type: File

outputs:
  exon_coverage_qc:
    label: Sample_ID_Failed_Exon_coverage_QC.txt
    doc: make Failed_Exon_coverage_QC.txt for PierianDx CGW
    type: File
    outputSource: make_coverage_QC/coverage_QC
  target_region_coverage_metrics:
    label: Sample_ID.TargetRegionCoverage.tsv
    doc: Consensus reads converage on TSO targeted regions.
    type: File
    outputSource: make_coverage_metrics/target_region_coverage_metrics

steps:
  mosdepth:
    run: ../tools/mosdepth-make-thresholds-bed.cwl
    label: mosdepth
    in:
      target_region_bed: tso_manifest_bed
      bam_or_cram: bam_file
      output_prefix:
        valueFrom: $(inputs.bam_or_cram.nameroot)
    out: [thresholds_bed_gz]
  make_coverage_QC:
    run: ../tools/mosdepth-thresholds-bed-to-coverage-QC-step.cwl
    label: make_coverage_QC.py
    in:
      thresholds_bed: mosdepth/thresholds_bed_gz
    out: [coverage_QC]
  make_coverage_metrics:
    run: ../tools/mosdepth-thresholds-bed-to-target-region-coverage.cwl
    label: target_region_coverage_metrics.py
    in:
      thresholds_bed: mosdepth/thresholds_bed_gz
    out: [target_region_coverage_metrics]
