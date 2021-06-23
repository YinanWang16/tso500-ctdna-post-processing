#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

baseCommand: [jq]
arguments:
  - -r
  - '.samples[]|select(.qualified).identifier'
  - valueFrom: $(> sample_id_list.txt")
    shellQuote: false
    position: 1

inputs:
  dsdm_json:
    type: File
    label: dsdm.json
    doc: dsdm.json file in Results folder
    inputBinding:
      position: 0

outputs:
  sample_id_list:
    type: string[]
    outputBinding:
      glob: sample_id_list.txt
      loadContents: true
      outputEval: $(self[0].contents)
      # problem still have: the file contents are not reads as a list of string but a whole
      # and it refuses to be split('\n') directly.
      #outputEval: $(self[0].contents.split(/\n/))
