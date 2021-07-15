#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: CommandLineTool

# Estentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

hints:
  - class: DockerRequirement
    dockerPull: umccr/alpine-rsync:3.2.3
  - class: ResourceRequirement
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

id: rsync files to subdir
label: rsync

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [ "rsync" ]

arguments:
  - --archive

inputs:
  file_list:
    type: File[]?
    doc: |
      List of input files to go into the output directory
    inputBinding:
      position: 1
  directory_list:
    type: Directory[]?
    doc:
      List of input Directories to go into the output directory
    inputBinding:
      position: 2
      # Strip trailing slash to ensure directory becomes a subdirectory
      valueFrom: |
        ${
          return self.map(function(a) {return a.path.replace(/\/$/, "")});
        }
  outdir_name:
    type: string
    label: output directory name
    inputBinding:
      position: 3
      # ensure one trailing slash
      valueFrom: |
        ${
          return self.replace(/\/$/, "") + "/";
        }

outputs:
  output_dir:
    type: Directory
    label: output directory
    doc: |
      The output directory with all of the outputs collected
    outputBinding:
      glob: "$(inputs.outdir_name)"
