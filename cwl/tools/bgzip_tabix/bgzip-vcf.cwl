#!/usr/bin/env cwl-runner

cwlVersion: v1.1
class: CommandLineTool

id: bgzip-vcf
label: bgzip-vcf

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.vcf)

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/tabix:1.11--hdfd78af_0
baseCommand: [bgzip]

inputs:
  vcf:
    type: File
    inputBinding:
      position: 0

outputs:
  vcf_gz:
    type: File
    outputBinding:
      glob: $(inputs.vcf.basename).gz
