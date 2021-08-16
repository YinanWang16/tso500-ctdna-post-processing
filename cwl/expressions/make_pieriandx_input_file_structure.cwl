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
  - id: copynumbervariants_vcf
    type: File
  - id: fusions_csv
    type: File
  - id: mergedsmallvariants_vcf
    type: File

expression: |
  ${ 
    var sample_id = inputs.sample_id;
    var r = {
      "outputs":
        { "class": "Directory",
          "basename": "tso500_ctDNA_output_folder",
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
                  "listing": [
                    inputs.copynumbervariants_vcf,
                    inputs.fusions_csv,
                    inputs.mergedsmallvariants_vcf ] } ] } ] } };
      return r;
    }

outputs:
  tso500_output: Directory
