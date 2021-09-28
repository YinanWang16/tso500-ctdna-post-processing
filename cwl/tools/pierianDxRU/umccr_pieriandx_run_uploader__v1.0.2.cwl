#!/usr/bin/env cwl-runner
cwlVersion: v1.2
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
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

requirements:
  - class: DockerRequirement
    dockerPull: amazoncorretto:8
  - class: InlineJavascriptRequirement
  - class: EnvVarRequirement
    envDef: 
      - "envName": "s3"
        "envValue": "new AWS.S3({signatureVersion: 'v4'})"
  - class: ShellCommandRequirement
  - class: InitialWorkDirRequirement
    listing: 
      - entry: $(inputs.pieriandx_run_uploader)
        entryname: $("/data/RunUploader-1.13.jar")
      - entry: $(inputs.s3_credential_file)
        entryname: $("/data/application.properties")
      - entry: $(inputs.msi_json)
        entryname: $("/data/TSO500_ctDNA_output/Logs_Intermediates/Msi/" + inputs.sample_id + "/" + inputs.sample_id + ".msi.json")
      - entry: $(inputs.tmb_json)
        entryname: $("/data/TSO500_ctDNA_output/Logs_Intermediates/Tmb/" + inputs.sample_id + "/" + inputs.sample_id + ".tmb.json")
      - entry: $(inputs.dsdm_json)
        entryname: $("/data/TSO500_ctDNA_output/Results/dsdm.json")
      - entry: $(inputs.copynumbervariants_vcf)
        entryname: $("/data/TSO500_ctDNA_output/Results/" + inputs.sample_id + "/" + inputs.sample_id + "_CopyNumberVariants.vcf")
      - entry: $(inputs.fusions_csv)
        entryname: $("/data/TSO500_ctDNA_output/Results/" + inputs.sample_id + "/" + inputs.sample_id + "_Fusions.csv")
      - entry: $(inputs.mergedsmallvariants_vcf)
        entryname: $("/data/TSO500_ctDNA_output/Results/" + inputs.sample_id + "/" + inputs.sample_id + "_MergedSmallVariants.vcf")
      - entry: $(inputs.sample_sheet)
        entryname: $("/data/SampleSheet.csv")
      - entryname: /data/run_pieriandx_run_uploader.sh
        entry: |-
          #!/usr/bin/env bash
          
          cd /data && java -jar -Dloader.main=com.pdx.commandLine.ApplicationCommandLine RunUploader-1.13.jar --commandLine --runFolder=/data/TSO500_ctDNA_output --runId=$(inputs.run_id) --sampleSheet=/data/SampleSheet.csv --sequencer=Illumina --sequencerFileType=$("\'" + inputs.sequencer_file_type + "\'")
            

baseCommand: [bash, /data/run_pieriandx_run_uploader.sh]

inputs:
  pieriandx_run_uploader:
    type: File
    doc: |
      RunUploader-1.13.jar (CGW Run uploader)
  command_line:
    type: boolean
    default: true
  run_folder:
    type: string
    doc: |
      GatheredResults directory of ICA TSO500 (solid/liquid) outputs.
    default: TSO500_ctDNA_output
  run_id:
    type: string
  sample_sheet:
    type: File
  sequencer:
    type: string
    default: "Illumina"
  sequencer_file_type:
    type: string
    doc: |
      TSO500 DRAGEN VCF workflows - tso500_v2_vcf
      TSO500 v1 and v2 HT VCF only workflow - TSO500 HT VCF only workflow
      TSO500 ctDNA VCF workflow - TSO500 ctDNA VCF Workflow
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
