cwlVersion: v1.0
class: Workflow
requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_file: File
  input_files: File[]
outputs:
  workflow_output_file:
    type: File
    outputSource: step1/output_file
steps:
  step1:
    run: ../tools/toolbox/cat-tool.cwl
    in:
      input_files:
        source:
          - input_file
          - input_files
        linkMerge: merge_flattened
    out: [output_file]
