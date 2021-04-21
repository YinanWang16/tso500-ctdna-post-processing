#!/staging/yinan/bin/python3.9
# This script is to make coverage metrics from mosdepth output {sample}.thresholds.bed.gz
# Author: Yinan Wang (ywang16@illumina.com)
# Date: Tue Feb  9 13:05:21 AEDT 2021

import pandas as pd
import gzip
import csv
import sys, getopt
import os.path

def usage():
	print(sys.argv[0] + ' -i <input_file> -o <output_file>')

def main():
	inputfile = ''
	outputfile = ''
	mean_family_size = ''
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hi:o:", ["help", "input=","output="])
	except getopt.GetoptError as err:
		print(err)
		usage()
		sys.exit(2)
	for opt, arg in opts:
		if opt in ('-h', '--help'):
			usage()
			sys.exit(2)
		elif opt in ('-i', '--input'):
			inputfile = arg
		elif opt in ('-o', '--output'):
			outputfile = arg
		else:
			assert False, usage()
			# sys.exit(2)
	# input file doesn't exist
	if not inputfile:
		usage()
		sys.exit(2)
	elif not os.path.isfile(inputfile):
		print(inputfile + ' not exist')
		sys.exit(2)
	# bed_file = '/staging/201221_A01052_0029_BHVTTNDMXX_DRAGEN_TSO500_ctDNA/Results_coverage_QC/PRJ200625_L2001084.thresholds.bed.gz'

	# open threshold.bed.gz file and load to data frame
	with gzip.open(inputfile) as i:
		data = pd.read_csv(i, sep='\t', header=0)
	#pd. DataFrame.head(data)

	# Calculate total length of targeted region
	length_sum = pd.DataFrame.sum(data['end'] - data['start'])

	with open(outputfile, 'w') as o:
		o.write('ConsensusReadDepth\tBasePair\tPercentage\n')
		o.write('TargetRegion\t' + str(length_sum) + '\t100%\n')
		for col in data.columns[4:]:
			threshold_pass_nt = pd.DataFrame.sum(data[col])
			percentage = format(threshold_pass_nt * 100 / length_sum, '.2f')
			o.write(col + '\t' + str(threshold_pass_nt) + '\t' +  str(percentage) + '%' + '\n')

if __name__ == "__main__":
   main()



