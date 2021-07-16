#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
doc: |
  Transforms sample specific outputs to match the desired output
label: per_sample_subdir_layout

requirements:
  - class: InlineJavascriptRequirement

inputs:
  file_list:
    type: File[]
  sample_id:
    type: string

expression: |
  ${
    var r = {
      "sample_subdir":
        { 
          "class": "Directory",
          "basename": inputs.sample_id,
          "listing": inputs.file_list
        }
    }
    return r;
  }

outputs:
  sample_subdir: Directory
