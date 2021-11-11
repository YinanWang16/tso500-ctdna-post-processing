#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

# Extentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

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
      - entryname: download_presigned_url_untar_to_dir.sh
        entry: |-
          #!/usr/bin/env bash
          # download file from presigned url
          curl -o $(inputs.out_file_name) $(inputs.presigned_url)
          # make output dir
          mkdir -p $(inputs.output_dir_name)
          # extract file and put to output dir
          tar -C $(inputs.output_dir_name) -xzvf $(inputs.out_file_name)

baseCommand: [bash, download_presigned_url_untar_to_dir.sh]

inputs:
    presigned_url:
        type: string
    out_file_name:
        type: string
    output_dir_name:
        type: string
outputs:
    output_dir:
        type: Directory
        outputBinding:
            glob: "$(inputs.output_dir_name)"
