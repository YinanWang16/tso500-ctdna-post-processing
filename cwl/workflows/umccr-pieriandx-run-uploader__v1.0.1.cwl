#!/usr/bin/env cwl-runner
cwlVersion: v1.2
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
  - class: InlineJavascriptRequirement
    expressionLib:
      - var get_tso500_ctdna_output_mounts = function (sample_id, dsdm_json, msi_json, tmb_json, results_file_list) {
          var dsdm_json_mount_point = "tso500_ctdna_output/Results/dsdm.json";
          var msi_json_mount_point = "tso500_ctdan_output/Logs_Intermediates/Msi/" + sample_id + "/" + sample_id + ".msi.json";
          var tmb_json_mount_point = "tso500_ctdan_output/Logs_Intermediates/Tmb/" + sample_id + "/" + sample_id + ".tmb.json";
          var copynumbervariants_vcf_mount_point = "tso500_ctdna_output/Results/" + sample_id + "/" + sample_id + "_CopyNumberVariants.vcf";
          var fusions_vcf_mount_point = "tso500_ctdna_output/Results/" + sample_id + "/" + sample_id + "_Fusions.csv";
          var mergedsmallvariants_vcf_mount_point = "tso500_ctdna_output/Results/" + sample_id + "/" + sample_id + "_MergedSmallVariants.vcf";
          var e = [
            {
              "entryname": dsdm_json_mount_point,
              "entry": dsdm_json
            },
            {
              "entryname": msi_json_mount_point,
              "entry": msi_json
            }
          ]
        }

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
  cgw_run_uploader_log:
    type: File
    outputSource: pieriandx_run_uploader_step/cgw_run_uploader_log

steps:
  get_msi_json_step:
    run: ../expressions/find-files-from-dir__v1.0.0.cwl
    in:
      input_dir: 
        source: tso500_outputs_by_sample
        valueFrom: $(self.msi_dir)
      file_basename_list:
        source: tso500_outputs_by_sample
        valueFrom: |
          ${
            return [self.sample_id + ".msi.json"]
          }
    out: [output_files]
  get_tmb_json_step:
    run: ../expressions/find-files-from-dir__v1.0.0.cwl
    in:
      input_dir: 
        source: tso500_outputs_by_sample
        valueFrom: $(self.tmb_dir)
      file_basename_list:
        source: tso500_outputs_by_sample
        valueFrom: |
          ${
            return [self.sample_id + ".tmb.json"]
          }
    out: [output_files]
  get_results_files_step:
    run: ../expressions/find-files-from-dir__v1.0.0.cwl
    in:
      input_dir: 
        source: tso500_outputs_by_sample
        valueFrom: $(self.results_dir)
      file_basename_list:
        source: tso500_outputs_by_sample
        valueFrom: |
          ${
            return [self.sample_id + "_CopyNumberVariants.vcf",
                    self.sample_id + "_Fusions.csv",
                    self.sample_id + "_MergedSmallVariants.vcf"];
          }
    out: [output_files]
  make_input_file_structure_step:
    run: ../expressions/make_pieriandx_input_file_structure.cwl
    in:
      msi_json: 
        source: get_msi_json_step/output_files
        valueFrom: $(self[0])
      tmb_json:
        source: get_tmb_json_step/output_files
        valueFrom: $(self[0])
      dsdm_json: 
        source: tso500_outputs_by_sample
        valueFrom: $(self.dsdm_json)
      sample_id: 
        source: tso500_outputs_by_sample
        valueFrom: $(self.sample_id)
      fusions_csv: 
        source: get_results_files_step/output_files
        valueFrom: $(self[0])
      mergedsmallvariants_vcf:
        source: get_results_files_step/output_files
        valueFrom: $(self[1])
      copynumbervariants_vcf: 
        source: get_results_files_step/output_files
        valueFrom: $(self[2])
    out: [tso500_output]
  pieriandx_run_uploader_step:
    run: ../tools/pierianDxRU/pieriandx_run_uploader.cwl
    in:
      pieriandx_run_uploader: pieriandx_run_uploader
      command_line: {default: true}
      run_folder: make_input_file_structure_step/tso500_output
      #  tso500_ctDNA_output_folder
      run_id: run_id
      sample_sheet: sample_sheet
      sequencer: {default: "Illumina"}
      sequencer_file_type: sequencer_file_type
      s3_credential_file: s3_credential_file
    out: [cgw_run_uploader_log]
      
