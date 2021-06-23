#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
doc: |
  Transforms sample specific outputs to match the desired output

requirements:
  - class: InlineJavascriptRequirement

inputs:
  list_of_files:
    type: File[]
  sample_id: 
    type: string

expression: |
  ${
    var r = {
      "sample_results":
        { "class": "Directory",
          "basename": inputs.sample_id,
          "listing": inputs.list_of_files
        }
    }
    return r;
  }
# works with inputs.list_of_files[0]
outputs:
  sample_results: Directory 
