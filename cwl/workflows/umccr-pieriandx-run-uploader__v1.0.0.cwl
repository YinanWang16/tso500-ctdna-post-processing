#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: Workflow

id: umccr-pieriandx-run-uploader
doc: |
  This is a pieriandx run uploader for UMCCR tso500 ctDNA output

requirements:
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../schemas/tso500-outputs-by-sample_1.0.0.yaml

inputs:
  tso500_outputs_by_sample:
    type: ../schemas/tso500-outputs-by-sample_1.0.0.yaml#tso500-outputs-by-sample
    doc: |
      Directories and Files of UMCCR tso500 outpout
  pieriandx_run_uploader:
    type: File
    doc: |
      RunUploader-1.13.jar (CGW Run uploader)
  run_id:
    type: string
    doc: |
      Run Id same as you would enter in CGW
      i.e. 190701_NDX550135_RUO_0039_AXXXXXXXXX
  sample_sheet:
    type: File
  sequencer_file_type:
    type: string
    doc: |
      TSO500 DRAGEN VCF workflows: "tso500_v2_vcf"
      TSO500 v1 and v2 HT VCF only workflow: "TSO500 HT VCF only workflow"
      TSO500 ctDNA VCF workflow: "TSO500 ctDNA VCF Workflow"
  s3_credential_file:
    type: File
    doc: |
      ‘application.properties’ file
      Update the below 3 lines in ‘application.properties’ file as described below:
        cgw.run.institution=[Add your institution name as given by PierianDx]
        cgw.run.s3.accessKey=[Add your AWS accessKey given by PierianDx]
        cgw.run.s3.secretKey=[Add your AWS secretKey given by PierianDx]

outputs:
  tso500_output: 
    type: Directory
    outputSource: make_input_file_structure_step/tso500_output
#  cgw_run_uploader_log:
#    type: File
#    outputSource: pieriandx_run_uploader_step/cgw_run_uploader_log

steps:
  get_inputs_files_per_sample_step:
    run: ../expressions/find-files-from-tso500-ctdna-output__v1.0.0.cwl
    in:
      tso500_outputs_by_sample: 
        source: tso500_outputs_by_sample
    out:
      - msi_json
      - tmb_json
      - vcfs
      - fusion_csv
      - sample_id
      - dsdm_json
  make_input_file_structure_step:
    run: ../expressions/make_pieriandx_input_file_structure.cwl
    in:
      tmb_json: get_inputs_files_per_sample_step/tmb_json
      msi_json: get_inputs_files_per_sample_step/msi_json
      dsdm_json: get_inputs_files_per_sample_step/dsdm_json
      sample_id: get_inputs_files_per_sample_step/sample_id
      fusions_csv: get_inputs_files_per_sample_step/fusion_csv
      mergedsmallvariants_vcf: 
        source: get_inputs_files_per_sample_step/vcfs
        valueFrom: |
          ${
            return self[2];
          }
      copynumbervariants_vcf:
        source: get_inputs_files_per_sample_step/vcfs
        valueFrom: |
          ${
            return self[0];
          }
    out: [tso500_output]
#  pieriandx_run_uploader_step:
#    run: ../tools/pierianDxRU/pieriandx_run_uploader.cwl
#    in:
#      pieriandx_run_uploader: pieriandx_run_uploader
#      command_line: {default: true}
#      run_folder: make_input_file_structure_step/tso500_output
#      run_id: run_id
#      sample_sheet: sample_sheet
#      sequencer: {default: "Illumina"}
#      sequencer_file_type: sequencer_file_type
#      s3_credential_file: s3_credential_file
#    output: [cgw_run_uploader_log]
      
