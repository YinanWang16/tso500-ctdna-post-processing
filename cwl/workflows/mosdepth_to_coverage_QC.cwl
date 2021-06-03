#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

# Extensions
$namespaces:
  s: https://schema.org/
s:license: "https://www.apache.org/licenses/LICENSE-2.0"

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
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  bam_file:
    label: raw bam
    doc: The path to the raw alignment bam file
    type: File
    secondaryFiles:
      - pattern: .bai
        required: true
  tso_manifest_bed:
    label: target region bed file
    doc: TSO manifest bed file
    type: File

outputs:
  exon_coverage_qc:
    label: Failed_Exon_coverage_QC.txt
    doc: For PierianDx CGW
    type: File
    outputSource: cat/output_file
  target_region_coverage_metrics:
    label: TargetRegionCoverage.tsv
    doc: Consensus reads converage on TSO targeted regions.
    type: File
    outputSource: coverage_metrics/target_region_coverage_metrics

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

  echo:
    in: []
    out: [header_file]
    run:
      class: CommandLineTool
      requirements:
        InitialWorkDirRequirement:
          listing:
            - entryname: header.sh
              entry: |
                echo -e "Level 2: 100x coverage for > 50% of positions was not achieved for the targeted exon regions listed below:"
                echo -e "index\tgene\ttranscript_acc\texon_id\tGE100\tGE250"
      inputs: []
      baseCommand: [bash, header.sh]
      stdout: header.txt
      outputs:
        header_file:
          type: stdout

  gunzip:
    run: ../tools/gunzip.cwl
    label: gunzip
    in:
      gz_file: mosdepth/thresholds_bed_gz
    out: [unzipped_file]

  coverage_QC:
    run: ../tools/mosdepth-awk-thresholds-bed-to-coverage-QC.cwl
    label: awk_coverage_QC
    in:
      thresholds_bed: gunzip/unzipped_file
    out: [coverage_QC]

  cat:
    run: ../tools/cat.cwl
    in:
      files:
        - echo/header_file
        - coverage_QC/coverage_QC
      outfile_name:
        valueFrom: $(inputs.files[1].nameroot)_Failed_Exon_coverage_QC.txt
    out: [output_file]
    label: cat

  coverage_metrics:
    run: ../tools/mosdepth-thresholds-bed-to-target-region-coverage.cwl
    label: target_region_coverage_metrics.py
    in:
      thresholds_bed: gunzip/unzipped_file
    out: [target_region_coverage_metrics]
