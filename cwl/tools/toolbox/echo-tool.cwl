#! /usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ['/bin/cat']
requirements:
  - class: DockerRequirement
    dockerPull: "bash:5"
stdout: "output.txt"
inputs:
  input_files:
    type: File[]
    inputBinding:
    position: 1
outputs:
  output_file:
    type: stdout
