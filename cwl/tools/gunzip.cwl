#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
id: gunzip file
label: gunzip file

baseCommand: 
  - gunzip
  - -c
requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.gz_file)

inputs:
  gz_file:
    type: File
    inputBinding:
      position: 0
stdout: $(inputs.gz_file.nameroot)
outputs:
  unzipped_file:
    type: stdout
