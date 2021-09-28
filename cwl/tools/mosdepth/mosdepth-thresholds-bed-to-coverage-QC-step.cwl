#!/usr/bin/env cwl-runner

cwlVersion: v1.1
class: CommandLineTool

$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

label: make_coverage_QC.py

hints:
  DockerRequirement:
    dockerPull: umccr/alpine_pandas:latest-cwl
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: thresholds-bed-to-coverage-QC.py
        entry: |
          #!/usr/bin/env python3

          import pandas as pd
          import re
          import argparse
          import gzip
          from os import path

          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='From mosdepth output "shreshold.bed" to generate "Failed_Exon_coverage_QC.txt" for PierianDx CGW')

              parser.add_argument('-i', '--input-bed', required=True,
                                  help='Mosdepth output file "threshold.bed.gz"')
              parser.add_argument('-s', '--sample-id', required=False,
                                  help='Sample_ID')
              return parser.parse_args()

          def main():
              """ Generate Failed_Exon_coverage_QC.txt """
              args = get_args()
              if not args.sample_id:
                  sample_id = path.basename(args.input_bed).split('.')[0]
              else:
                  sample_id = args.sample_id
              coverage_csv = sample_id + '_Failed_Exon_coverage_QC.txt'
              with gzip.open(args.input_bed) as b:
                  data = pd.read_csv(b, sep='\t', header=0)
              # define header of the file
              header = 'Level 2: 100x coverage for > 50% of positions was not achieved for the targeted exon regions listed below:\n'
              header += 'index\tgene\ttranscript_acc\texon_id\tGE100\tGE250\n'
              with open(coverage_csv, 'w') as o:
                  o.write(header)
                  for i in range(len(data)):
                      exon_length = data.loc[i, 'end'] - data.loc[i, 'start']
                      PCT100 = data.loc[i, '100X'] / exon_length * 100
                      index = data.loc[i, 'region']
                      name = index.split('_')
                      if (len(name) < 3): # regions other than exons
                          continue
                      gene, exon_id, transcript_acc = index.split('_')
                      if PCT100 < 50 and re.match('^NM', transcript_acc):
                          PCT250 = data.loc[i, '250X'] / exon_length * 100
                          try:
                              exon_id = int(re.sub('Exon', '', exon_id))
                          except:
                              exon_id = int(re.sub('Intron', '', exon_id))
                          o.write('%s\t%s\t%s\t%d\t%.1f\t%.1f\n' % (index, gene, transcript_acc, exon_id, PCT100, PCT250))
          main()

baseCommand: ["python3", "thresholds-bed-to-coverage-QC.py"]
inputs:
  thresholds_bed:
    type: File
    label: thresholds.bed.gz
    doc: mosdepth output thresholds.bed.gz
    inputBinding:
      prefix: -i
      position: 0
  sample_id:
    type: string?
    label: Sample_ID
    inputBinding:
      prefix: -s
      position: 1
outputs:
  coverage_QC:
    type: File
    outputBinding:
      glob: "$(inputs.thresholds_bed.nameroot.split('.')[0])_Failed_Exon_coverage_QC.txt"
