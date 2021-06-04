#!/usr/bin/env python3
# Author: Yinan Wang (ywang16@illumina.com)
# Date: 2021-05-19T16:01:39+10:00

import argparse
from os import path
import pandas as pd
import re

def get_args():
  """ Get arguments for the command """
  parser = argparse.ArgumentParser(description='From mosdepth output "shreshold.bed" to generate "Failed_Exon_coverage_QC.txt" for PierianDx CGW')

  parser.add_argument('-i', '--input-bed', required=True,
                      help='Mosdepth output file "threshold.bed", ungzipped')
  return parser.parse_args()

def main():
  """ Generate Failed_Exon_coverage_QC.txt """
  args = get_args()
  sample_id = path.basename(args.input_bed).split('.')[0]
  coverage_csv = sample_id + '_Failed_Exon_coverage_QC.txt'
  with open(args.input_bed) as b:
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
              exon_id = int(re.sub('Exon', '', exon_id))
              o.write('%s\t%s\t%s\t%d\t%.1f\t%.1f\n' % (index, gene, transcript_acc, exon_id, PCT100, PCT250))
main()

