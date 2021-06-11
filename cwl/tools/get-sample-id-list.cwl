#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Extentions
$namespaces:
  s: https://schema.org/
  ilmn-tes: https://platform.illumina/rdf/ica/
# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

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
  InitialWorkDirRequirement:
    listing:
      - $(inputs.tso500_output_dir)

#baseCommand: [ls]

#arguments:
#  - -LRl
#  - $(runtime.outdir)

inputs:
  tso500_output_dir:
    label: tso500-output-dir
    doc: |
      The output directory of TSO500 analysis
      (gds://path/to/wrn.xxx/GatheredResults)
    type: Directory

outputs:
  sample_id_list:
    label: Sample_ID list
    doc: |
      List of succeeded Sample_ID
    type: Directory
    outputBinding:
      glob: "$(get_dsdm_json_path())"
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

# about the code
s:dateCreated: 2021-06-10
s:codeRepository:
