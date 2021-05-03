#!/usr/bin/env python3
# This script is to split Results/MetricsOutput.tsv into per sample tsv in sample subfolder
# Author: Yinan Wang (ywang16@illumina.com)
# Date: 2021-04-22T10:50:18+10:00
import pandas as pd
import re
import os

def get_sample_list(file):
    with open(file, 'rt') as f:
        for line in f:
            if 'Metric (UOM)' in line and 'Value' not in line: # get the sample_ID line
                line = re.sub('\n$', '', line)
                samples = line.split('\t')
                return samples[3:]

def make_sample_subdir_and_sub_MetricsOutput_list(file, samples):
    file_path = os.path.dirname(file)
    if not samples:
        samples = get_sample_list(file)
    sample_file_list = []
    for sample in samples:
        sample_subdir = file_path + '/' + sample
        if not os.path.exists(sample_subdir):
            os.mkdir(sample_subdir)
        sample_file = sample_subdir + '/' + sample + '_MetricsOutput.tsv'
        sample_file_list += [sample_file]
    return samples, sample_file_list

def convert_section_tb_to_df(section_tb):
    # make analysis status data frame
    section_df = pd.DataFrame(section_tb)
    # replace column name with the first row
    # and drop the first row
    section_df.columns = section_df.iloc[0,]
    section_df.drop([0,], inplace = True)
    # replace index with the first column
    # and drop the first column
    section_df.index = section_df.iloc[:,0]
    section_df.drop(section_df.columns[0], axis = 'columns', inplace = True)
    return(section_df)

def print_to_per_sample_file(section, data, samples, sample_file_list):
    if isinstance(data, str):   # data is strings
        for  i in range(len(samples)):
            with open(sample_file_list[i], 'at') as f:
                f.write(data)
    elif isinstance(data, pd.DataFrame):    # data is strings
        if section == 'Analysis Status':    # section 'Analysis Status' doesn't have 'LSL Guideline', 'USL Guideline'
            for i in range(len(samples)):
                data[samples[i]].to_csv(sample_file_list[i], sep = '\t', mode = 'a')
        else:
            for i in range(len(samples)):
                data[['LSL Guideline', 'USL Guideline', samples[i]]].to_csv(sample_file_list[i], sep = '\t', mode = 'a')
                #
                # print(data[['LSL Guideline', 'USL Guideline', samples[i]]])

def read_MetricsOutput_and_print_sample_file(file, samples):
    samples, sample_file_list = make_sample_subdir_and_sub_MetricsOutput_list(file, samples)
    other_sections = ['Header', 'Run Metrics', 'Notes']
    with open(file, 'rt') as f:
        section_name = ''
        for line in f:
            m = re.match('\[(.*)\]', line)    # Match the name of a section to initiate a data frame.
            if m:   # section_name line
                section_name = m.group(1)
                print_to_per_sample_file(section_name, '\n' + line, samples, sample_file_list)
                section_tb = []   # Initiate/clear section table to store section data.
            elif re.match('^\t{3,}', line):   # empty line
                if section_name and section_tb: # is the end of a data section
                    section_df = convert_section_tb_to_df(section_tb)
                    print_to_per_sample_file(section_name, section_df, samples, sample_file_list)
            else:   # data line
                if section_name:
                    if section_name in other_sections:
                        print_to_per_sample_file(section_name, line, samples, sample_file_list)
                    else:
                        line = re.sub('\t*\n$', '', line)
                        section_tb += [line.split('\t')]
                else:
                    print_to_per_sample_file(section_name, line, samples, sample_file_list)

MetricsOutput_file = 'example_data/MetricsOutput.tsv'
samples = []
read_MetricsOutput_and_print_sample_file(MetricsOutput_file, samples)
