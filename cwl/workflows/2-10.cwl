#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sh, /WORK/nscc-gz_material_4/vasp/1-1/1-2/1-3/2-1/check4.sh] 
inputs: 
  210f:
    type: File
outputs:
  ch4:
    type: stdout
stdout: ch4.txt
