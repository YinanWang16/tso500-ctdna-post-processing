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

hints:
  DockerRequirement:
    dockerPull: ubuntu:latest
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

id: gunzip files
label: gunzip
doc: gunzip files

baseCommand: ["gunzip"]

arguments: 
  - -c
  - valueFrom: $("> " + inputs.gz_file.nameroot)
    shellQuote: false
    position: 1

inputs:
  gz_file:
    type: File
    inputBinding:
      position: 0

outputs:
  unzipped_file:
    type: File
    outputBinding:
      glob: $(inputs.gz_file.nameroot)


