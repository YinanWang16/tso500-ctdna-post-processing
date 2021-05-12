#!/usr/bin/env python3
# Author: Yinan Wang (ywang16@illumina.com)
# Date: 2021-05-11T11:35:08+10:00

import pandas as pd
import json
import csv
import re
import sys, getopt

def usage():
    print(sys.argv[0] + ' <Full_Path_to/TSO500_Output_Folder')
    sys.exist(2)

def get_sample_list(TSO500_OUTPUT_FOLDER):
    dsdm_json = TSO500_OUTPUT_FOLDER + "/Results/dsdm.json"
    with open(dsdm_json, "rt") as f:
        data = json.load(f)
    sample_list = [d['identifier'] for d in data['samples']]
    return sample_list

def string_or_list(value):
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
        metrics_data.append({'name': row[2],
                            'value': string_or_list(row[3]),
                            'percent': float(row[4]),
                            })
    else:
        metrics_data.append({'name': row[2],
                            'value': string_or_list(row[3]),
                            })
    return(metrics_data)

def make_metrics_dic(file):
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
    # locat metrics_csv_file
    prefix = TSO500_OUTPUT_FOLDER + '/Logs_Intermediates/AlignCollapseFusionCaller/' + sample_id + '/' + sample_id
    trimmer_metrics = prefix + '.trimmer_metrics.csv'
    mapping_metrics = prefix + '.mapping_metrics.csv'
    umi_metrics = prefix + '.umi_metrics.csv'
    wgs_coverage_metrics = prefix + '.wgs_coverage_metrics.csv'
    sv_metrics = prefix + '.sv_metrics.csv'
    time_metrics = prefix + '.time_metrics.csv'
    metrics_csv_list = [trimmer_metrics,
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
    MY_TSO500_OUTPUT_FOLDER = ''
    try:
        MY_TSO500_OUTPUT_FOLDER = sys.argv[1]
    except getopt.GetoptError as err:
        print(err)
        usage()
    SAMPLES = get_sample_list(MY_TSO500_OUTPUT_FOLDER)
    OUTPUT_DIR = MY_TSO500_OUTPUT_FOLDER + '/Results'
    for sample in SAMPLES:
        sample_dic = make_metrics_json(MY_TSO500_OUTPUT_FOLDER, sample)
        output_json = OUTPUT_DIR + '/' + sample + '/' + sample + '.AlignCollapseFusionCaller_metrics.json'
        with open(output_json, 'w') as json_file:
            json.dumps(sample_dic, json_file)

if __name__ == "__main__":
   main()
