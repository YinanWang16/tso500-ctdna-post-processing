#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: ExpressionTool

# Extentions
$namespaces:
  s: https://schema.org/
# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

# label/doc
id: get-sample-id-from-file-name
label: get-sample-id
doc: |
  This expression tool is to get "Sample_Id" from file name of
  {Sample_Id}.description[].suffix

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_sample_id = function(){
              /*
              Get inputs.output_prefix value, fall back to the prefix of inputs.input_file nameroot
              */
              if (inputs.output_prefix !== null) {
                return inputs.output_prefix;
              }
              return inputs.input_file.nameroot.split('.')[0];
            }
inputs:
  input_file:
    type: string
    label: intput_file
    doc: |
      path to the input file which is leaded by sample_id
      {Sample_Id}.description[].suffix
  output_prefix:
    type: string?

Outputs:
  sample_id:
    type: string
    label: sample_id

expression: >-
  ${
    return {"sample_id": get_sample_id()};
  }


# about the code
s:dateCreated: 2021-06-03
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processing
