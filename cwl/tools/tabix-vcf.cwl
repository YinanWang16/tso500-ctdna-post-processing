#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
id: tabix-vcf
label: tabix-vcf

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/tabix:1.11--hdfd78af_0
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.vcf)

baseCommand: [tabix, -p, vcf]
arguments: 
  - $(inputs.vcf)

inputs:
  vcf:
    type: File
    
outputs:
  tbi:
    type: File
    outputBinding:
      glob: $(inputs.vcf.basename).tbi
    

