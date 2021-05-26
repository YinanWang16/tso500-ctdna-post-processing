#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
id: gunzip files
doc: gunzip files

baseCommand: ["gunzip"]
arguments: ["-c"]

inputs:
  gz_file:
    type: File
    inputBinding:
      position: 0

outputs:
  unzipped_file:
    type: stdout

stdout: $(inputs.gz_file.nameroot)

