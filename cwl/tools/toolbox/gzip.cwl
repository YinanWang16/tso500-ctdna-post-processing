#!/usr/bin/env cwl-runner
cwlVersion: v1.1
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

hints:
  DockerRequirement:
    dockerPull: ubuntu:latest
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

id: gzip file
label: gzip file

baseCommand:
  - gzip
  - -c

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.file)

inputs:
  file:
    type: File
    inputBinding:
      position: 0

stdout: $(inputs.file.basename).gz

outputs:
  gzipped_file:
    type: stdout
