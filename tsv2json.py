#!/usr/bin/env python3
# Author: Yinan Wang (ywang16@illumina)
# date: 2021-05-12T18:58:56+10:00

import pandas as pd
import numpy as np
import json
import sys, getopt

def usage():
    print(sys.argv[0] + ' -i <tsv_file> -s <skip_rows>')
    sys.exit(2)

def tsv2json(tsv_file, skip_rows):
    df = pd.read_csv(tsv_file, sep='\t', header=0, comment='#', skiprows = skip_rows)
    variants = []
    for i in range(len(df)):
        variants.append(dict(df.iloc[i,]))
    return(variants)

def convert(o):
    if isinstance(o, np.generic): return o.item()
    raise TypeError

def main():
    skip_rows = 0
    tsv_file = ''
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'hi:s:', ['help', 'input=', 'skiprows='])
    except getopt.GetoptError as err:
        print(err)
        usage()
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt in ('-i', '--input'):
            tsv_file = arg
        elif opt in ('-s', '--skiprows'):
            skip_rows = int(arg)
        else:
            assert False, usage()
    if not tsv_file:
        usage()

    json_file = tsv_file.rsplit('.', 1)[0] + '.json'
    variant_df = tsv2json(tsv_file, skip_rows)
    with open(json_file, 'w') as jf:
        json.dump(variant_df, jf, default=convert)

main()
