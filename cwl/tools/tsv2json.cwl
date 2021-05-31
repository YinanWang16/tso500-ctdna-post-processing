#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.0

id: tsv2json
label: tsv2json

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

          # Set logging level
          logging.basicConfig(level=logging.DEBUG)

          # Get arguments
          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='Covnert tsv to json')

              # Arguments
              parser.add_argument('-i', '--input', required=True,
                                  help="Input tsv file")
              parser.add_argument('-s', '--skip-rows', required=False,
                                  default=0, type=int,
                                  help="Skip first n rows of the tsv file")
              return parser.parse_args()

          def tsv2json(tsv_file, skip_rows):
              """ make tsv data to dictionary """
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
              tsv_file = args.input
              json_file = os.path.basename(tsv_file.rsplit('.', 1)[0] + '.json')
              variant_df = tsv2json(tsv_file, args.skip_rows)
              with open(json_file, 'w') as jf:
                  json.dump(variant_df, jf, default=convert)

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
  json_file:
    type: File
    outputBinding:
      glob: "$(inputs.tsv_file.nameroot).json"
