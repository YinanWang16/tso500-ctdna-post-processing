#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [ssh, ln1, yhbatch]
arguments: [/WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/run_vasp4.sh, -N, "1"]
inputs: []
outputs:
  yh4:
    type: stdout
stdout: yh4.txt
