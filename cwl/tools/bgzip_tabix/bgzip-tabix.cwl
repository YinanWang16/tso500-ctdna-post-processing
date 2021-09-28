#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: CommandLineTool

id: bgzip-tabix-vcf
label: bgzip-tabix

$namespaces:
  ilmn-tes: http://platform.illumina.com/rdf/ica/

hints:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/tabix:1.11--hdfd78af_0
  - class: ResourceRequirement
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: 
      - entryname: bgzip-tabix-vcf.sh
        entry: |-
          #!/usr/bin/bash
          
          # vcf file list
          for vcf in \${@}; do
              bgzip -c \${vcf} >\${vcf}.gz
              tabix -p vcf \${vcf}.gz 
          done
      - $(inputs.vcf)

baseCommand: ["bash", "bgzip-tabix-vcf.sh"]

inputs:
  vcf:
    type: File[]
    label: vcf
    inputBinding:
      position: 0
outputs:
  vcf_gz:
    type: File[]
    label: vcf.gz, vcv.gz.tbi
    outputBinding:
      glob: "*.vcf.gz*"
      
