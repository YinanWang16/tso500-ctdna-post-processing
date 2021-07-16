#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

id: single-sample-post-processing
label: single-sample-post-processing
doc: tso500 ctdDNA post-processing for single sample

requirements:
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  tso500_ctdna_output: Directory
  sample_id: string
  tso_manifest_bed: File

outputs:
  results_sample_subdir:
    type: Directory
    outputSource: per_sample_subdir_layout/sample_subdir

steps:
  get_inputs_files_per_sample:
    run: ../expressions/locate-inputs-files-per-sample.cwl
    in:
      tso500_ctdna_output_dir:
        source: tso500_ctdna_output
      sample_id:
        source: sample_id
    out:
      - raw_bam 
      - raw_bai 
      - raw_bam_md5sum  
      - evidence_bam  
      - evidence_bai  
      - mapping_metrics_csv 
      - trimmer_metrics_csv 
      - umi_metrics_csv 
      - wgs_coverage_metrics_csv
      - sv_metrics_csv
      - time_metrics_csv
      - fragment_length_hist_csv
      - msi_json
      - tmb_json
      - sampleanalysisresults_json
      - cleaned_stitched_bam
      - cleaned_stitched_bai
      - vcfs
      - fusion_csv
      - mergedsmallvariantsannotated_json_gz
      - tmb_trace_tsv
  mosdepth:
    run: ../tools/mosdepth/mosdepth-make-thresholds-bed.cwl
    label: mosdepth
    in:
      target_region_bed: tso_manifest_bed
      bam_or_cram: get_inputs_files_per_sample/raw_bam
      bai: get_inputs_files_per_sample/raw_bai
      threshold_bases: {default: [100, 250, 500, 750, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 8000, 10000]}
      no_per_base: {default: true}
      output_prefix: sample_id
    out: [thresholds_bed_gz]
  make_coverage_QC:
    run: ../tools/mosdepth/mosdepth-thresholds-bed-to-coverage-QC-step.cwl
    label: make_coverage_QC.py
    in:
      thresholds_bed: mosdepth/thresholds_bed_gz
    out: [coverage_QC]
  make_coverage_metrics:
    run: ../tools/mosdepth/mosdepth-thresholds-bed-to-target-region-coverage.cwl
    label: target_region_coverage_metrics.py
    in:
      thresholds_bed: mosdepth/thresholds_bed_gz
    out: [target_region_coverage_metrics]
  bgzip_tabix:
    run: ../tools/bgzip_tabix/bgzip-tabix.cwl
    label: bgzip-tabix
    in:
      vcf: get_inputs_files_per_sample/vcfs
    out: [vcf_gz]
  dragen_metrics_csv2json:
    run: ../tools/dragen_metrics/dragen-metrics-csv2json.cwl
    label: dragen_metrics_csv2json
    in:
      mapping_metrics_csv: get_inputs_files_per_sample/mapping_metrics_csv
      trimmer_metrics_csv: get_inputs_files_per_sample/trimmer_metrics_csv
      umi_metrics_csv: get_inputs_files_per_sample/umi_metrics_csv
      wgs_coverage_metrics_csv: get_inputs_files_per_sample/wgs_coverage_metrics_csv
      sv_metrics_csv: get_inputs_files_per_sample/sv_metrics_csv
      time_metrics_csv: get_inputs_files_per_sample/time_metrics_csv
    out: [metrics_json_gz]
  tsv_to_json_gz:
    run: ../tools/tsv2json/tsv2json.cwl
    label: tsv2json
    in:
      tsv_file:
        - get_inputs_files_per_sample/tmb_trace_tsv
        - get_inputs_files_per_sample/fragment_length_hist_csv
        - get_inputs_files_per_sample/fusion_csv
        - make_coverage_QC/coverage_QC
        - make_coverage_metrics/target_region_coverage_metrics
    out: [json_gz_file]
  gzip:
    run: ../tools/toolbox/gzip.cwl
    label: gzip
    in:
      files_to_compress:
        - get_inputs_files_per_sample/msi_json
        - get_inputs_files_per_sample/tmb_json
        - get_inputs_files_per_sample/sampleanalysisresults_json
    out: [gzipped_files]
  per_sample_subdir_layout:
    run: ../expressions/per_sample_subdir_layout.cwl
    label: sample_subdir_layout
    in:
      sample_id: sample_id
      file_list:
        source:
          - get_inputs_files_per_sample/evidence_bam  #1
          - get_inputs_files_per_sample/evidence_bai  #2
          - get_inputs_files_per_sample/raw_bam #3
          - get_inputs_files_per_sample/raw_bai #4
          - get_inputs_files_per_sample/raw_bam_md5sum  #5
          - get_inputs_files_per_sample/cleaned_stitched_bam  #6
          - get_inputs_files_per_sample/cleaned_stitched_bai  #7
          - get_inputs_files_per_sample/mergedsmallvariantsannotated_json_gz  #8
          - dragen_metrics_csv2json/metrics_json_gz #9
          - bgzip_tabix/vcf_gz  #10 6f
          - make_coverage_QC/coverage_QC  #11
          - tsv_to_json_gz/json_gz_file #12 5f
          - gzip/gzipped_files  #13 3f
        linkMerge: merge_flattened
    out: [sample_subdir]
