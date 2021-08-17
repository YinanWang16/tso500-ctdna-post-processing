#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

# Extentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

# label/doc
id: PierianDx_Run_Uploader
label: PierianDx_Run_Uploader
doc: |
  This is a PierianDx Run Uploader for TSO500

hints:
  DockerRequirement:
    dockerPull: amazoncorretto:8
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

requirements:
  - class: InitialWorkDirRequirement
    listing: 
      - $(inputs.pieriandx_run_uploader)
      - $(inputs.s3_credential)
      - $(inputs.run_folder)

baseCommand: [java, -jar]
arguments:
  - -Dloader.main=com.pdx.commandLine.ApplicationCommandLine

inputs:
  pieriandx_run_uploader:
    type: File
    doc: |
      RunUploader-1.13.jar (CGW Run uploader)
    inputBinding:
      position: 0
      valueFrom: $(self.basename)
  command_line:
    type: boolean
    default: true
    inputBinding:
      prefix: --commandLine
      position: 1
  run_folder:
    type: Directory
    doc: |
      "GatheredResults" directory of ICA TSO500 (solid/liquid) outputs.
    inputBinding:
      prefix: --runFolder=
      separate: false
      position: 2
      valueFrom: $(self.basename)
  run_id:
    type: string
    inputBinding:
      prefix: --runId=
      separate: false
      position: 3
  sample_sheet:
    type: File
    inputBinding:
      prefix: --sampleSheet=
      separate: false
      position: 4
  sequencer:
    type: string
    default: "Illumina"
    inputBinding:
      prefix: --sequencer=
      separate: false
      position: 5
  sequencer_file_type:
    type: string
    doc: |
      TSO500 DRAGEN VCF workflows: "tso500_v2_vcf"
      TSO500 v1 and v2 HT VCF only workflow: "TSO500 HT VCF only workflow"
      TSO500 ctDNA VCF workflow: "TSO500 ctDNA VCF Workflow"
    inputBinding:
      prefix: --sequencerFileType=
      separate: false
      position: 6
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
    outputBinding:
      glob: "cgwRunUploader.log"

# about the code
#s:dateCreated: 2021-06-07
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processing
