#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

id: mosdepth-thresholds-bed
doc: use mosdepth to make threshold.bed file for calculating Failed_Exon_coverage_QC.txt

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/mosdepth:0.3.1--ha7ba039_0
baseCommand: mosdepth

inputs:
  threads:
    type: int
    doc: |
      number of BAM decompression threads [default: 0]
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
    inputBinding:
        prefix: -T
        itemSeparator: ","
        position: 2
  no_per_base:
    type: boolean
    doc: |
      don't output per-base depth. skipping this output will speed execution
      substantially. prefer quantized or thresholded values if possible.
    inputBinding:
      prefix: -n
      position: 3
  output_prefix:
    type: string
    inputBinding:
      position: 4
  bam_or_cram:
    type: File
    doc: the alignment file for which to calculate depth.
    inputBinding:
      position: 5
    secondaryFiles: .bai

outputs:
  thresholds_bed:
    type: File
    outputBinding:
      glob: $(inputs.bam_or_cram.nameroot).thresholds.bed.gz
