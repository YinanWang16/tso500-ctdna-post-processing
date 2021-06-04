#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs: []
steps:
  yh2:
    run: 2-1.cwl
    in: []
    out: [yh4]
  mk2:
    run: 2-11.cwl
    in: []
    out: [mk4]
  check2:
    run: 2-10.cwl
    in: 
      210f: yh2/yh4
    out: [ch4]
  cp2:
    run: 2-12.cwl
    in:
      cpf1: yh2/yh4
      cpf2: mk2/mk4
      cpf3: check2/ch4
    out: [cp4]
outputs:
  step1file:
    type: File
    outputSource: cp2/cp4
  
