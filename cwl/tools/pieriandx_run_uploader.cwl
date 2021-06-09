#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Extentions
$namespaces:
  s: https://schema.org/
  ilmn-tes: https://platform.illumina/rdf/ica/
# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

# label/doc
id: PierianDx_Run_Uploader
label: PierianDx_Run_Uploader
doc: |
  This is a PierianDx Run Uploader for TSO

hints:
  DockerRequirement:
    dockerPull: amazoncorretto:8
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: medium
      coreMin: 4
      ramMin: 2048
      
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.pieriandx_run_uploader)
      - $(inputs.s3_credential)
baseCommand: [java, -jar]
arguments:
  - -Dloader.main=com.pdx.commandLine.ApplicationCommandLine

inputs:
  pieriandx_run_uploader:
    type: File
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
    inputBinding:
      prefix: --sequencerFileType=
      separate: false
      position: 6
  s3_credential:
    type: File

outputs:
  cgw_run_uploader_log:
    type: File
    outputBinding:
      glob: "cgwRunUploader.log"


# about the code
#s:dateCreated: 2021-06-07
s:codeRepository: https://github.com/YinanWang16/TSO500-Liftover
