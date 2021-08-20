#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool

doc: |
  Given list of requested files and Sample_ID, 
  create the desired TSO500 file structure.
label: make PierianDx input file structure

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: sample_id
    type: string
  - id: dsdm_json
    type: File
  - id: msi_json
    type: File
  - id: tmb_json
    type: File
  - id: results_file_list
    type: File[]

expression: >-
  ${ 
    var sample_id = inputs.sample_id;
    var r = {
      "tso500_output":
        { "class": "Directory",
          "basename": "TSO500_ctDNA_output",
          "listing": [
            { "class": "Directory",
              "basename": "Logs_Intermediates",
              "listing": [
                { "class": "Directory",
                  "basename": "Msi",
                  "listing": [
                    { "class": "Directory",
                      "basename": sample_id,
                      "listing": [
                        inputs.msi_json ] } ] },
                { "class": "Directory",
                  "basename": "Tmb",
                  "listing": [
                    { "class": "Directory",
                      "basename": sample_id,
                      "listing": [
                        inputs.tmb_json ] } ] } ] },
            { "class": "Directory",
              "basename": "Results",
              "listing": [
                inputs.dsdm_json,
                { "class": "Directory",
                  "basename": sample_id,
                  "listing": inputs.results_file_list } ] } ] } };
      return r;
    }

outputs:
  tso500_output: Directory
