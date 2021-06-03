#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

id: mosdepth-thresholds-bed
doc: use mosdepth to make threshold.bed file for calculating Failed_Exon_coverage_QC.txt

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/mosdepth:0.3.1--ha7ba039_0

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_output_prefix(){
              /*
              Get inputs.output_prefix value, fall back to inputs.bam_or_cram nameroot
              */
              if (input.output_prefix == null){
                return inputs.output_prefix
              }
            }

baseCommand: [mosdepth]
arguments:
  # output_prefix
  - valueFrom: "$(get_output_prefix())"
    position: 4

inputs:
  threads:
    type: int
    doc: |
      number of BAM decompression threads [default: 0]
    default: 4
    inputBinding:
      prefix: -t
      position: 0
  target_region_bed:
    type: File
    doc: TSO manifest bed file
    inputBinding:
      prefix: -b
      position: 1
  threshold_bases:
    type: int[]
    doc: |
      for each interval in --by, write number of bases covered by at
      least threshold bases.
    default: [100, 250, 500, 750, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 8000, 10000]
    inputBinding:
        prefix: -T
        itemSeparator: ","
        position: 2
  no_per_base:
    type: boolean
    doc: |
      don't output per-base depth. skipping this output will speed execution
      substantially. prefer quantized or thresholded values if possible.
    default: true
    inputBinding:
      prefix: -n
      position: 3
  output_prefix:
    type: string?
  bam_or_cram:
    type: File
    doc: the alignment file for which to calculate depth.
    inputBinding:
      position: 5
    secondaryFiles:
      - pattern: .bai
        required: true

outputs:
  thresholds_bed_gz:
    type: File
    outputBinding:
      glob: $(inputs.bam_or_cram.nameroot).thresholds.bed.gz
