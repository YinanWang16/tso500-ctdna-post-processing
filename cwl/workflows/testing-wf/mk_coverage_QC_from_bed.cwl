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
label: make Failed_Exon_coverage_QC.txt for pierianDx CGW
doc: |
  Input is mosdepth output 'threshold.bed.gz'.
  Outputs are 'Failed_Exon_coverage_QC.txt' and 'target_region_coverage_metrics'.

# about the code
# s:dateCreated: 2021-05-30
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processing

inputs:
  threshold_bed_gz: File
  sample: string

outputs:
  exon_coverage_qc:
    type: File
    outputSource: cat/coverage_QC_txt
  target_region_coverage_metrics:
     type: File
     outputSource: coverage_metrics/target_region_coverage_metrics

steps:
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
    in:
      gz_file: threshold_bed_gz
    out: [unzipped_file]

  coverage_QC:
    run: ../tools/mosdepth-awk-thresholds-bed-to-coverage-QC.cwl
    in:
      thresholds_bed: gunzip/unzipped_file
      sample_id: sample
    out: [coverage_QC]

  cat:
    in:
      header_txt: echo/header_file
      coverage_QC_data: coverage_QC/coverage_QC
    out: [coverage_QC_txt]
    run:
      class: CommandLineTool
      baseCommand: [cat]
      inputs:
        header_txt:
          type: File
          inputBinding:
            position: 0
        coverage_QC_data:
          type: File
          inputBinding:
            position: 1
      stdout: $(inputs.coverage_QC_data.nameroot)_Failed_Exon_coverage_QC.txt
      outputs:
          coverage_QC_txt:
            type: stdout

  coverage_metrics:
    run: ../tools/mosdepth-thresholds-bed-to-target-region-coverage.cwl
    in:
      thresholds_bed: gunzip/unzipped_file
      sample_id: sample
    out: [target_region_coverage_metrics]
