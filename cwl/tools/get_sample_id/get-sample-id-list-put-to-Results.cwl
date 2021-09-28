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
      - var get_dsdm_json_path = function() {
          return "Results/dsdm.json";
        }
          # return inputs.tso500_output_dir.basename + "/" + "Results" + "/" + "dsdm.json";
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
  - class: ShellCommandRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.tso500_output_dir.listing)
        writable: true

#baseCommand: [ls]
baseCommand: []

#arguments:
#  - -Rl
#  - valueFrom: $("> Results/ls.txt")
#    shellQuote: false

inputs:
  tso500_output_dir:
    label: tso500-output-dir
    doc: |
      The output directory of TSO500 analysis
      (gds://path/to/wrn.xxx/GatheredResults)
    type: Directory

outputs:
  sample_id_list:
    type: string[]
    doc: |
      List of succeeded Sample_ID
    outputBinding:
      loadContents: true
      glob: "$(get_dsdm_json_path())"
      outputEval: $(get_succeeded_sample_id_list(self[0].contents))
  results_folder:
    type: Directory
    outputBinding:
      glob: "Results"
