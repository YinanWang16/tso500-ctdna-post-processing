#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

id: single-sample-post-processing
label: single-sample-post-processing
doc: tso500 ctdDNA post-processing for single sample

requirements:
  - class: StepInputExpressionRequirement

inputs:
  tso500_ctdna_output: Directory
  sample: string
  tso_manifest_bed: File

outputs:
  exon_coverage_qc:
    type: File
    outputSource: make_coverage_QC/coverage_QC
  target_region_coverage_metrics:
    type: File
    outputSource: make_coverage_metrics/target_region_coverage_metrics

steps:
  get_raw_bam_step:
    run: ../expressions/locate-inputs-files-per-sample.cwl
    in:
      tso500_ctdna_output_dir:
        source: tso500_ctdna_output
      sample_id:
        source: sample
    out:
      - raw_bam
  mosdepth:
    run: ../tools/mosdepth-make-thresholds-bed.cwl
    label: mosdepth
    in:
      target_region_bed: tso_manifest_bed
      bam_or_cram: get_raw_bam_step/raw_bam
      threshold_bases: {default: [100, 250, 500, 750, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 8000, 10000]}
      no_per_base: {default: true}
      output_prefix: sample
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

