#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: CommandLineTool

id: tabix-vcf
label: tabix-vcf

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/tabix:1.11--hdfd78af_0
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.vcf_gz)

baseCommand: [tabix, -p, vcf]

inputs:
  vcf_gz:
    type: File
    inputBinding:
      position: 0

outputs:
  tbi:
    type: File
    outputBinding:
      glob: "$(inputs.vcf_gz.basename).tbi"
