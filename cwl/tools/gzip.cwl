#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
id: gzip file
label: gzip file

baseCommand:
  - gzip
  - -c

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.file)

inputs:
  file:
    type: File
    inputBinding:
      position: 0

stdout: $(inputs.file.basename).gz

outputs:
  gzipped_file:
    type: stdout

