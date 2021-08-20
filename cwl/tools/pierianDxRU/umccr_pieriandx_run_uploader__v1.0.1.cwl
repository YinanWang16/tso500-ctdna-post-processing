#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Note the run upload only works under v1.0 but not compatible with v1.1+

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
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: 
      - $(inputs.pieriandx_run_uploader)
      - $(inputs.s3_credential_file)
      - entry: $(inputs.msi_json)
        entryname: $("TSO500_ctDNA_output/Logs_Intermediates/Msi/" + inputs.sample_id + "/" + inputs.sample_id + ".msi.json")
      - entry: $(inputs.tmb_json)
        entryname: $("TSO500_ctDNA_output/Logs_Intermediates/Tmb/" + inputs.sample_id + "/" + inputs.sample_id + ".tmb.json")
      - entry: $(inputs.dsdm_json)
        entryname: $("TSO500_ctDNA_output/Results/dsdm.json")
      - entry: $(inputs.copynumbervariants_vcf)
        entryname: $("TSO500_ctDNA_output/Results/" + inputs.sample_id + "/" + inputs.sample_id + "_CopyNumberVariants.vcf")
      - entry: $(inputs.fusions_csv)
        entryname: $("TSO500_ctDNA_output/Results/" + inputs.sample_id + "/" + inputs.sample_id + "_Fusions.csv")
      - entry: $(inputs.mergedsmallvariants_vcf)
        entryname: $("TSO500_ctDNA_output/Results/" + inputs.sample_id + "/" + inputs.sample_id + "_MergedSmallVariants.vcf")

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
    type: string
    doc: |
      GatheredResults directory of ICA TSO500 (solid/liquid) outputs.
    default: TSO500_ctDNA_output
    inputBinding:
      prefix: --runFolder=
      separate: false
      position: 2
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
      TSO500 DRAGEN VCF workflows - tso500_v2_vcf
      TSO500 v1 and v2 HT VCF only workflow - TSO500 HT VCF only workflow
      TSO500 ctDNA VCF workflow - TSO500 ctDNA VCF Workflow
    inputBinding:
      prefix: --sequencerFileType=
      separate: false
      position: 6
  s3_credential_file:
    type: File
    doc: |
      the application.properties file
      Update the below 3 lines in ‘application.properties’ file as described below
        cgw.run.institution=[Add your institution name as given by PierianDx]
        cgw.run.s3.accessKey=[Add your AWS accessKey given by PierianDx]
        cgw.run.s3.secretKey=[Add your AWS secretKey given by PierianDx]
  sample_id:
    type: string
  msi_json:
    type: File
  tmb_json:
    type: File
  dsdm_json:
    type: File
  fusions_csv:
    type: File
  mergedsmallvariants_vcf:
    type: File
  copynumbervariants_vcf:
    type: File

outputs:
  cgw_run_uploader_log:
    type: File
    outputBinding:
      glob: "cgwRunUploader.log"

# about the code
#s:dateCreated: 2021-06-07
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processing
