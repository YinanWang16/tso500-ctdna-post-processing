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
          import sys
          import argparse
          import gzip

          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='Covnert AlignCollapseFusionCaller/*metrics.csv to json')

              # add Arguments
              parser.add_argument('-d', '--tso500-output-dir', required=True,
                                  help='TSO500/ctTSO500 analysis output directory')
              
              return parser.parse_args()

          def get_sample_list(TSO500_OUTPUT_FOLDER):
              """ get sample list from dsdm.json """
              dsdm_json = TSO500_OUTPUT_FOLDER + "/Results/dsdm.json"
              with open(dsdm_json, "rt") as f:
                  data = json.load(f)
              sample_list = [d['identifier'] for d in data['samples']]
              return sample_list

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
                  # Doesn't have persontage
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

          def make_metrics_json(TSO500_OUTPUT_FOLDER, sample_id):
              """ output json file """
              # locat metrics_csv_file
              prefix = TSO500_OUTPUT_FOLDER + '/Logs_Intermediates/AlignCollapseFusionCaller/' + sample_id + '/' + sample_id
              trimmer_metrics = prefix + '.trimmer_metrics.csv'
              mapping_metrics = prefix + '.mapping_metrics.csv'
              umi_metrics = prefix + '.umi_metrics.csv'
              wgs_coverage_metrics = prefix + '.wgs_coverage_metrics.csv'
              sv_metrics = prefix + '.sv_metrics.csv'
              time_metrics = prefix + '.time_metrics.csv'
              metrics_csv_list = [
                                  trimmer_metrics,
                                  mapping_metrics,
                                  umi_metrics,
                                  wgs_coverage_metrics,
                                  sv_metrics,
                                  time_metrics,
                                  ]
              # make the metrics dictonary.
              metrics_dic = {}
              for csv_file in metrics_csv_list:
                  metrics_dic.update(make_metrics_dic(csv_file))
              return metrics_dic

          def main():
              args = get_args()
              tso500_output_dir = args.tso500_output_dir
              sample_list = get_sample_list(tso500_output_dir)
              for sample in sample_list:
                  sample_dic = make_metrics_json(tso500_output_dir, sample)
                  output_json = sample + '_AlignCollapseFusionCaller_metrics.json'
                  output_gz = output_json + '.gz'
                  with gzip.open(output_gz, 'wt', encoding='ascii') as zipfile:
                      json.dump(sample_dic, zipfile)

          main()

baseCommand: ["python3", "AlignCollapseFusionCaller_metrics.csv2json.py"]

inputs:
  tso500_output_dir:
    type: Directory
    inputBinding:
      prefix: "--tso500-output-dir"
      position: 0
  
outputs:
  metrics_json:
    type: File
    outputBinding:
      glob: "*_AlignCollapseFusionCaller_metrics.json.gz"
