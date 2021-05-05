#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [echo, -e]

inputs:
  content:
    type: string
    inputBinding:
      position: 0
stdout: header.txt
outputs:
  output_file:
    type: stdout
