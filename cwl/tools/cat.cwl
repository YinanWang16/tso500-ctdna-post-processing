#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Extentions
$namespaces:
  s: https://schema.org/
# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

# label/doc
id: cat_files
label: cat_files
doc: cat list of files and save to the same outpout

requirements:
  InlineJavascriptRequirement: {}
baseCommand: [cat]

inputs:
  files:
    type: File[]
    inputBinding:
      position: 0
  outfile_name:
    type: string

stdout: $(inputs.outfile_name)
outputs:
  output_file:
    type: stdout

# about the code
s:dateCreated: 2021-06-01
s:codeRepository: