#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Extentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

# label/doc
id: get_sample_id_list
label: get_sample_id_list
doc: |
  Get successfully analyzed Sample_ID from Results/dsdm.json

# Docker and resources
hints:
  # DockerRequirement:
  #   dockerPull:
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
#      type: stardard
#      size: small

requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - var get_dsdm_json_path = function() {
          return inputs.tso500_output_dir.path + "/" + "Results" + "/" + "dsdm.json";
        }
      - var load_dsdm_json_content = function() {
          var dsdm_json_file = get_dsdm_json_path
          fetch(dsdm
      - var get_succeeded_sample_id_list = function(dsdm_contents) {
          var dsdmOjb = JSON.parse(dsdm_contents);
          console.log(dsdmObj);
          var jp = require('jsonpath);
          var sample_id_list = jp.query(dsdmObj, '$.samples[?(@.qualified)].identifier')
          return sample_id_list
        }
  InitialWorkDirRequirement:
    listing:
      - $(inputs.tso500_output_dir.listing)
      #- $(inputs.tso500_output_dir)

baseCommand: [jq]

arguments:
  - -r
  - '.samples[]|select(.qualified).identifier'
  - $(get_dsdm_json_path())

inputs:
  tso500_output_dir:
    label: tso500-output-dir
    doc: |
      The output directory of TSO500 analysis
      (gds://path/to/wrn.xxx/GatheredResults)
    type: Directory

stdout: list_samples.txt

outputs:
  sample_id_list:
    label: Sample_ID list
    doc: |
      List of succeeded Sample_ID
    type: stdout
      
      #glob: "$(get_dsdm_json_path())"
      # glob: "$(inputs.tso500_output_dir.basename)"
#    type: string[]
#    outputBinding:
#      loadContents: true
#      glob: "$(get_dsdm_json_path())"
#      outputEval: |-
#        ${
#          var dsdmObj = JSON.parse(self[0].contents)
#          console.log(dsdmObj);
#          return dsdmObj;
#        }

