#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.0

id: AlignCollapseFusionCaller_metrics.csv2json
label: convert AlignCollapseFusionCaller_metrics.csv to json

requirements:
  DockerRequirement:
    dockerPull: umccr/alpine_pandas:latest-cwl
  InitialWorkDirRequirement:
    listing:
      - entryname: AlignCollapseFusionCaller_metrics.csv2json.py
        entry: |
          #!/usr/bin/ev python3

          import pandas as pd
          import json
          import csv
          import re
          from os import path
          import argparse
          import gzip

          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='Convert AlignCollapseFusionCaller/*metrics.csv to json')

              # add Arguments
              parser.add_argument('--mapping-metrics', required=True,
                                  help='Sample_ID.mapping_metrics.csv')
              parser.add_argument('--trimmer-metrics', required=True,
                                  help='Sample_ID.trimmer_metrics.csv')
              parser.add_argument('--umi-metrics', required=True,
                                  help='Sample_ID.umi_metrics.csv')
              parser.add_argument('--sv-metrics', required=True,
                                  help='Sample_ID.sv_metrics.csv')
              parser.add_argument('--wgs-coverage-metrics', required=True,
                                  help='Sample_ID.wgs_metrics.csv')
              parser.add_argument('--time-metrics', required=True,
                                  help='Sample_ID.time_metrics.csv')
              parser.add_argument('--sample-id', required=False,
                                  help='Sample_ID')
              
              return parser.parse_args()

          def string_or_list(value):
              """ return a string or list of a value"""
              if re.match(r'^{.*}$', value):
                  value = re.sub('{|}', '', value)
                  list = [int(s) for s in value.split('|')]
                  return (list)
              else:
                  try:
                      return float(value)
                  except:
                      return value

          def append_row_to_metrics_data(row, metrics_data):
              if len(row) == 5:
                  # has percentage column
                  metrics_data.append({
                                      'name': row[2],
                                      'value': string_or_list(row[3]),
                                      'percent': float(row[4]),
                                      })
              else:
                  # Doesn't have percentage
                  metrics_data.append({
                                      'name': row[2],
                                      'value': string_or_list(row[3]),
                                      })
              return(metrics_data)

          def make_metrics_dic(file):
              """ read in data of file and convert to dictionary """
              with open(file, 'r') as csvfile:
                  csv_reader = csv.reader(csvfile, delimiter=',')
                  metrics_data = []
                  metrics_name = ''
                  metrics_dic = {}
                  for row in csv_reader:
                      if row[0] == metrics_name:     # the same metrics data type
                          metrics_data = append_row_to_metrics_data(row, metrics_data)
                      elif not metrics_name:         # first line, metrics data is empty
                          metrics_name = row[0]
                          metrics_data = append_row_to_metrics_data(row, metrics_data)
                      elif metrics_name != row[0]:   # a new metrics data type
                          metrics_name_formatted = re.sub(' |/', '', metrics_name.title())
                          metrics_dic[metrics_name_formatted] = metrics_data
                          # initiate a new metrics data type
                          metrics_name = row[0]
                          metrics_data = []
                  metrics_name_formatted = re.sub(' |/', '', metrics_name.title())
                  metrics_dic[metrics_name_formatted] = metrics_data
                  return metrics_dic

          def make_metrics_json(file_list, sample_id):
              """ output json file """
              # make the metrics dictonary.
              metrics_dic = {}
              for file in file_list:
                  metrics_dic.update(make_metrics_dic(file))
              return metrics_dic

          def main():
              args = get_args()
              metrics_file_list = [
                                    args.mapping_metrics,
                                    args.trimmer_metrics,
                                    args.umi_metrics,
                                    args.wgs_coverage_metrics,
                                    args.sv_metrics,
                                    args.time_metrics,
                                  ]
              
              # define output file prefix
              if not args.sample_id:
                  sample_id = path.basename(args.mapping_metrics).split('.')[0]
              else:
                  sample_id = args.sample_id

              sample_dic = make_metrics_json(metrics_file_list, sample_id)
              output_json = sample_id + '.AlignCollapseFusionCaller_metrics.json'
              output_gz = output_json + '.gz'
              with gzip.open(output_gz, 'wt', encoding='ascii') as zipfile:
                  json.dump(sample_dic, zipfile)

          main()

baseCommand: ["python3", "AlignCollapseFusionCaller_metrics.csv2json.py"]

inputs:
  mapping_metrics_csv:
    type: File
    inputBinding:
      prefix: "--mapping-metrics"
  trimmer_metrics_csv:
    type: File
    inputBinding:
      prefix: "--trimmer-metrics"
  umi_metrics_csv:
    type: File
    inputBinding:
      prefix: "--umi-metrics"
  wgs_coverage_metrics_csv:
    type: File
    inputBinding:
      prefix: "--wgs-coverage-metrics"
  sv_metrics_csv:
    type: File
    inputBinding:
      prefix: "--sv-metrics"
  time_metrics_csv:
    type: File
    inputBinding:
      prefix: "--time-metrics"
  
outputs:
  metrics_json:
    type: File
    outputBinding:
      glob: "*.AlignCollapseFusionCaller_metrics.json.gz"
