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
  - class: InitialWorkDirRequirement
    listing:
      - entryname: download_presigned_url_untar_to_dir.sh
        entry: |-
          #!/usr/bin/env sh
          set -euo pipefail

          # download file from presigned url
          echo "curl -o temp.tar.gz $(inputs.presigned_url)"
          curl -o temp.tar.gz "$(inputs.presigned_url)"

          # make output dir
          mkdir -p $(inputs.output_dir_name)

          # extract file and put to output dir
          tar -C $(inputs.output_dir_name) -xzvf temp.tar.gz

baseCommand: ["sh", "download_presigned_url_untar_to_dir.sh"]

inputs:
    presigned_url:
        type: string
        doc: presigned url for tar.gz file
    output_dir_name:
        type: string
outputs:
    output_dir:
        type: Directory
        outputBinding:
            glob: "$(inputs.output_dir_name)"
