#!/usr/bin/env python3
# Author: Yinan Wang (ywang16@illumina)
# date: 2021-05-12T18:58:56+10:00

import pandas as pd
import numpy as np
import json
import os
import logging
import argparse

def get_args():
    """ Get arguments for the command """
    parser = argparse.ArgumentParser(description='Covnert tsv to json')

    # Arguments
    parser.add_argument('-i', '--input', required=True,
                        help="Input tsv file")
    parser.add_argument('-s', '--separator', required=False,
                        help="File separator")

    parser.add_argument('-s', '--skip-rows', required=False,
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
    json_file = tsv_file.rsplit('.', 1)[0] + '.json'
    variant_df = tsv2json(tsv_file, args.skip_rows)
    with open(json_file, 'w') as jf:
        json.dump(variant_df, jf, default=convert)

main()
