#!/usr/bin/env cwl-runner

cwlVersion: v1.1
class: CommandLineTool

$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

id: make_sample_subdir
label: make-sample-subdir-results

hints:
  - class: DockerRequirement
    dockerPull: ubuntu:latest
  - class: ResourceRequirement
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small
requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: copy_files.sh
        entry: |-
          #!/usr/bin/env bash

          sample=\${1}; shift
          mkdir -p \${sample}

          cp \${@} \${sample}

baseCommand: ["bash", "copy_files.sh"]

inputs:
  sample_id:
    type: string
    label: sample_id
    inputBinding:
      position: 0
  file_list:
    type: File[]
    doc: files to put in sample_id subdir
    inputBinding:
      position: 1

outputs:
  sample_subdir:
    label: sample-subdir
    type: Directory
    outputBinding:
      glob: "$(inputs.sample_id)"
