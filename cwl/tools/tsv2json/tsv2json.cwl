#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.1

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
              parser.add_argument('-i', '--input', type=argparse.FileType('r'),
                                  required=True, nargs='+',
                                  help="Input tsv/csv files, separate by space.")
              parser.add_argument('-r', '--skip-rows', required=False,
                                  default=0, type=int,
                                  help="Skip first n rows of the tsv file")
              return parser.parse_args()

          def tsv2json(tsv_file, skip_rows):
              """ make tsv data to dictionary """
              if tsv_file.name.endswith(".csv"):
                  df = pd.read_csv(tsv_file, sep=',', header=0, comment='#', skiprows=skip_rows)
              else:
                  df = pd.read_csv(tsv_file, sep='\t', header=0, comment='#', skiprows=skip_rows)
              variants = []
              for i in range(len(df)):
                  variants.append(dict(df.iloc[i,]))
              return variants

          def convert(o):
              """ convert np.int64 to string """
              if isinstance(o, np.generic): return o.item()
              raise TypeError

          def main():
              args = get_args()
              for file in args.input:
                  json_file = path.basename(file.name).rsplit('.', 1)[0] + '.json.gz'
                  variant_df = tsv2json(file, args.skip_rows)
                  with gzip.open(json_file, 'wt', encoding='ascii') as jf:
                      json.dump(variant_df, jf, default=convert)

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
    type: int?
    inputBinding:
      prefix: "--skip-rows"
      position: 1

outputs:
  json_gz_file:
    type: File[]
    outputBinding:
      glob: "*.json.gz"
