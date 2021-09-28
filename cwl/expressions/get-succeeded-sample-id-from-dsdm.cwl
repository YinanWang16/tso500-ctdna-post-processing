#!/usr/bin/env cwlrunner

cwlVersion: v1.1
class: ExpressionTool

doc: |
  From "Results/dsdm.json" output succeeded Sample_ID list

requirements:
  - class: InlineJavascriptRequirement

inputs:
  dsdm_json:
    type: File
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

