#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Extentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

hints:
  - class: DockerRequirement
    dockerPull: curlimages/curl:7.80.0
  - class: ResourceRequirement
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [curl]

inputs:
    presigned_url:
        type: string
        inputBinding:
          position: 1
    file_name:
        type: string
        inputBinding:
          prefix: -o
          position: 0
outputs:
    output_file:
        type: File
        outputBinding:
            glob: "$(inputs.file_name)"
