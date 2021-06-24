#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: CommandLineTool

# Extentions
# $namespaces:
#   ilmn-tes: https://platform.illumina/rdf/ica/

hints:
  - class: DockerRequirement
    dockerPull: ubuntu:latest
  # - class: ResourceRequirement
  #   ilmn-tes:resources:
  #     tier: standard
  #     type: standard
  #     size: small

id: gzip list of files
label: gzip

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: gzip_list_of_files.sh
        entry: |-
          #!/usr/bin/bash
          for f in \${@}; do
            gzip -c \$f >\${f}.gz
          done
      - $(inputs.files_to_compress)

baseCommand: [bash, gzip_list_of_files.sh]

inputs:
  files_to_compress:
    type: File[]
    inputBinding:
      position: 0

outputs:
  gzipped_files:
    type: File[]
    outputBinding:
      glob: "*.gz"
