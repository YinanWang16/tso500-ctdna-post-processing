#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: CommandLineTool

# Extentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

# label/doc
id: get_sample_id_list
label: get_sample_id_list
doc: |
  Get successfully analyzed Sample_ID from Results/dsdm.json

#hints:
#  ResourceRequirement:
#    ilmn-tes:resources:
#      tier: standard

requirements:
  - class: InlineJavascriptRequirement
    expressionLib:
      - var get_succeeded_sample_id_list = function(dsdm_contents) {
          var dsdmObj = JSON.parse(dsdm_contents);
          var sample_id_list = [];
          for (var i = 0; i < dsdmObj.samples.length; i++) {
            if (dsdmObj.samples[i].qualified) {
              sample_id_list.push(dsdmObj.samples[i].identifier);
            }
          }
          return sample_id_list;
        }
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.dsdm_json)

baseCommand: [ls]

inputs:
  dsdm_json:
    label: dsdm.json
    doc: |
      dsdm.json under Results/ directory
    type: File

outputs:
  sample_id_list:
    type: string[]
    doc: |
      List of succeeded Sample_ID
    outputBinding:
      loadContents: true
      glob: $(inputs.dsdm_json.basename)
      outputEval: $(get_succeeded_sample_id_list(self[0].contents))
