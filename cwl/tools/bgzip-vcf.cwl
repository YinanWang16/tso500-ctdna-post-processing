#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: bgzip-vcf
label: bgzip-vcf

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/tabix:1.11--hdfd78af_0
baseCommand: bgzip

inputs:
  vcf:
    type: File
    inputBinding:
      position: 0
      prefix: -c

stdout: $(inputs.vcf.basename).gz
outputs:
  bgzipped_vcf:
    type: stdout


