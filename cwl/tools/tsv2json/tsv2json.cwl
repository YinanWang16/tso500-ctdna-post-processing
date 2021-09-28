#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.1

$namespaces:
  ilmn-tes: http://platform.illumina.com/rdf/ica/

hints:
  - class: ResourceRequirement
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

id: tsv2json
label: tsv2json.py

requirements:
  - class: DockerRequirement
    dockerPull: umccr/alpine_pandas:latest-cwl
  - class: ShellCommandRequirement  
  - class: InlineJavascriptRequirement
  - class:  InitialWorkDirRequirement
    listing:
      - entryname: tsv2json.py
        entry: |
          #!/usr/bin/env python3

          import pandas as pd
          import numpy as np
          import json
          from os import path
          import argparse
          import gzip

          # Get arguments
          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='Covnert tsv to json')

              # Arguments
              parser.add_argument('-i', '--input-file', type=argparse.FileType('r'),
                                  required=True, nargs='+',
                                  help="Input tsv/csv files, separate by space.")
              parser.add_argument('-r', '--skip-rows', required=False,
                                  default=0, type=int, nargs='+',
                                  help="Skip first n rows for each of the tsv file, separate by space")
              return parser.parse_args()

          def tsv2json(tsv_file, skip_rows):
              """ make tsv data to dictionary """
              if tsv_file.name.endswith(".csv"):
                  df = pd.read_csv(tsv_file, sep=',', header=0, comment='#', skiprows=skip_rows)
              else:
                  df = pd.read_csv(tsv_file, sep='\t', header=0, comment='#', skiprows=skip_rows)
              
              return df

          def convert(o):
              """ convert np.int64 to string """
              if isinstance(o, np.generic): return o.item()
              raise TypeError

          def main():
              args = get_args()
              for i in range(len(args.input_file)):
                  # get tsv file and number of skipped rows
                  tsv_file = args.input_file[i]
                  skip_rows = args.skip_rows[i]
                
                  
                  json_file = path.basename(tsv_file.name).rsplit('.', 1)[0] + '.json.gz'
                  tsv_df = tsv2json(tsv_file, args.skip_rows[i])

                  tsv_df.to_json(json_file, orient="records", force_ascii=True, compression="gzip")

          main()

baseCommand: ["python3", "tsv2json.py"]

inputs:
  tsv_file:
    type: File[]
    inputBinding:
      prefix: "--input"
      position: 0
      itemSeparator: " "
      shellQuote: false
  skiprows:
    type: int[]?
    inputBinding:
      prefix: "--skip-rows"
      position: 1

outputs:
  json_gz_file:
    type: File[]
    outputBinding:
      glob: "*.json.gz"
