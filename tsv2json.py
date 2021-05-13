#!/usr/bin/env python3
# Author: Yinan Wang (ywang16@illumina)
# date: 2021-05-12T18:58:56+10:00

import pandas as pd
import numpy as np
import json
import sys, getopt

def usage():
    print(sys.argv[0] + ' <tsv_file>')
    sys.exit(2)

def tsv2json(tsv_file):
    df = pd.read_csv(tsv_file, sep='\t', header=0 )
    variants = []
    for i in range(len(df)):
        variants.append(dict(df.iloc[i,]))
    return(variants)

def convert(o):
    if isinstance(o, np.generic): return o.item()
    raise TypeError

def main():
    if len(sys.argv) == 1:
        usage()
    else:
        tsv_file = sys.argv[1]

    json_file = tsv_file.replace('tsv', 'json')
    variant_df = tsv2json(tsv_file)
    with open(json_file, 'w') as jf:
        json.dump(variant_df, jf, default=convert)

main()
