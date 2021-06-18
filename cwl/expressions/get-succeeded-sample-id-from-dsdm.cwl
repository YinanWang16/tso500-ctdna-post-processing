#!/usr/bin/env cwlrunner

cwlVersion: v1.0
class: ExpressionTool

doc: |
  Locate "Results/dsdm.json" and output succeeded Sample_ID list

requirements:
  - class: InlineJavascriptRequirement
#    expressionLib:
#      - var get_succeeded_sample_id_list = function(dsdm_contents) {
#          var dsdmObj = JSON.parse(dsdm_contents);
#          var sample_id_list = [];
#          for (var i = 0; i < dsdmObj.samples.length; i++) {
#            if (dsdmObj.samples[i].qualified) {
#              sample_id_list.push(dsdmObj.samples[i].identifier);
#            }
#          }
#          return sample_id_list;
#        }

inputs:
  dsdm_json:
    type: File
    inputBinding:
      loadContents: true

expression: >
  ${
    var get_succeeded_sample_id_list = function(contents) {
      var dsdmObj = JSON.parse(contents);
      var succeededSamples = [];
      for (var i = 0; i < dsdmObj.samples.length; i++) {
        if (dsdmObj.samples[i].qualified) {
          succeededSamples.push(dsdmObj.samples[i].identifier);
        }
      }
      return succeededSamples;
    }
    var dsdm_contents = inputs.dsdm_json.contents;
    var sampleArray = get_succeeded_sample_id_list(dsdm_contents);
    return {'sample_id_list': sampleArray};
  }

outputs:
  sample_id_list:
    type: string[]
    doc: |
      List of succeeded Sample_ID
#    outputBinding:
#      loadContents: true
#      glob: "$inputs.dsdm_json.basename"
#      outputEval: $(get_succeeded_sample_id_list(self[0].contents))

