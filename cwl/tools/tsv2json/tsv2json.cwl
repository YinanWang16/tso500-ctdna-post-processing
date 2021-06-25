#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.1

id: tsv2json
label: tsv2json.py

requirements:
  DockerRequirement:
    dockerPull: umccr/alpine_pandas:latest-cwl
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: tsv2json.py
        entry: |
          #!/usr/bin/env python3

          import pandas as pd
          import numpy as np
          import json
          import os
          import logging
          import argparse
          import gzip

          # Set logging level
          logging.basicConfig(level=logging.DEBUG)

          # Get arguments
          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='Covnert tsv to json')

              # Arguments
              parser.add_argument('-i', '--input', required=True,
                                  help="Input tsv file")
              parser.add_argument('-s', '--separator', required=False,
                                  type=str,
                                  help="File separator")
              parser.add_argument('-r', '--skip-rows', required=False,
                                  default=0, type=int,
                                  help="Skip first n rows of the tsv file")
              return parser.parse_args()

          def tsv2json(tsv_file, separator, skip_rows):
              """ make tsv data to dictionary """
              if separator:
                  df = pd.read_csv(tsv_file, sep=separator, header=0, comment='#', skiprows=skip_rows)
              elif tsv_file.endswith(".tsv"):
                  df = pd.read_csv(tsv_file, sep='\t', header=0, comment='#', skiprows=skip_rows)
              elif tsv_file.endswith(".csv"):
                  df = pd.read_csv(tsv_file, sep=',', header=0, comment='#', skiprows=skip_rows)
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
              tsv_file = args.input
              json_file = os.path.basename(tsv_file.rsplit('.', 1)[0] + '.json.gz')
              variant_df = tsv2json(tsv_file, args.separator, args.skip_rows)
              # with open(json_file, 'w') as jf:
              #    json.dump(variant_df, jf, default=convert)
              with gzip.open(json_file, 'wt', encoding='ascii') as zipfile:
                  json.dump(variant_df, zipfile, default=convert)

          main()

baseCommand: ["python3", "tsv2json.py"]

inputs:
  tsv_file:
    type: File
    inputBinding:
      prefix: "--input"
      position: 0
  skiprows:
    type: int?
    inputBinding:
      prefix: "--skiprows"
      position: 1

outputs:
  json_gz_file:
    type: File
    outputBinding:
      glob: "$(inputs.tsv_file.nameroot).json.gz"
