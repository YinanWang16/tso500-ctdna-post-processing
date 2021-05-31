#!/usr/bin/env python3
# This script is to make coverage metrics from mosdepth output {sample}.thresholds.bed.gz
# Author: Yinan Wang (ywang16@illumina.com)
# Date: Tue Feb  9 13:05:21 AEDT 2021

import pandas as pd
from os import path
import argparse

def get_args():
    """ Get arguments for the command """
    parser = argparse.ArgumentParser(description='From mosdepth threshold.bed to make target_region_coverage_metrics.csv')

    # add arguments
    parser.add_argument('-i', '--input-bed', required=True,
                        help='Mosdepth output file "threshold.bed", ungzipped')
    return parser.parse_args()

def main():
    """ Calculate consensus reads coverage metrics """
    args = get_args()
    thresholds_bed = args.input_bed
    sample_id = path.basename(thresholds_bed).split('.')[0]
    output_csv = sample_id + '_TargetRegionCoverage.csv'

    # open threshold.bed file and load to dataframe
    with open(thresholds_bed, 'rt') as i:
        data = pd.read_csv(i, sep='\t', header=0)
    # calculate total legnth of targeted region
    length_sum = pd.DataFrame.sum(data['end'] - data['start'])
    # write results to file
    with open(output_csv, 'w') as o:
        o.write('ConsensusReadDepth\tBasePair\tPercentage\n')
        o.write('TargetRegion\t' + str(length_sum) + '\t100%\n')
        for col in data.columns[4:]:
            threshold_pass_nt = pd.DataFrame.sum(data[col])
            percentage = format(threshold_pass_nt * 100 / length_sum, '.2f')
            o.write(col + '\t' + str(threshold_pass_nt) + '\t' +  str(percentage) + '%' + '\n')
main()
