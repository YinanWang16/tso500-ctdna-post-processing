#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool

$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

id: make_sample_subdir
label: make-sample-subdir-results

hints:
  - class: ResourceRequirement
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small
requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: /data/copy_files.sh
        entry: |-
          #!/usr/bin/env bash
          sample=$(inputs.sample_id)
          mkdir -p \${sample}
          cp \${@} \${sample}

baseCommand: ["bash", "/data/copy_files.sh"]

inputs:
  sample_id:
    type: string
    label: sample_id
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
