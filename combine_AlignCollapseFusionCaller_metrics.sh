#!/bin/bash
# This script is to combine DRAGEN QC metrics files under DRAGEN_TSO500_ctDNA_output/Logs_Intermediates/AlignCollapseFusionCaller
# to save a single metrics.csv of all samples to Results folder
# Author: Yinan Wang (ywang16@illumina.com)
# Date:Fri Feb  5 10:45:00 AEDT 2021

# =============== Help page ============== ##
USAGE="Usage: $0 -d <PATH_TO_TSO500_OUTPUT> -h -v"
VERSION=1.0
HELP () {
        echo $USAGE
        exit 1
}
## ======================================== ##

## ============== Parameters ============== ##
# empty enter;
if [ $# -eq 0 ];
then
    HELP
fi

# get options
while getopts ":d:hv" opt; do
        case ${opt} in
                h) HELP
                ;;
                v) echo $VERSION
                exit 0;;
                d) TSO500_OUTDIR=$OPTARG
                ;;
                \*) echo "Error: Invalad option"
                HELP;;
        esac
done

if [ ! -d $TSO500_OUTDIR ]; then
        echo "Error: $TSO500_OUTDIR doesn't exit"
        HELP
fi
## ======================================== ##

## ================ Settings ==================== ##
METRICS_DIR=$TSO500_OUTDIR/Logs_Intermediates/AlignCollapseFusionCaller
SUFFIX=(trimmer_metrics.csv mapping_metrics.csv umi_metrics.csv wgs_coverage_metrics.csv sv_metrics.csv time_metrics.csv)
#SUFFIX=(trimmer_metrics.csv mapping_metrics.csv fastqc_metrics.csv umi_metrics.csv wgs_coverage_metrics.csv sv_metrics.csv time_metrics.csv)
tmp=$TSO500_OUTDIR/Results/tmp.csv
SUMMARY=$TSO500_OUTDIR/Results/AlignCollapseFusionCaller_metrics.csv
## ============================================== ##

## ============== Make header ===================== ##
# get sample list
SAMPLES=(`jq -r '.samples[].identifier' $TSO500_OUTDIR/Results/dsdm.json`)

HEADER="Sample_ID,Percentage (%),"
for sample in ${SAMPLES[@]}; do
	HEADER+="$sample,%"
done
echo $HEADER >$SUMMARY
## ================================================ ##

## ============== Add content ===================== ##
# make combined metrics
for suff in ${SUFFIX[@]}; do
	TYPE=$(basename $suff .csv)
	TYPE=$(echo $TYPE|tr [:lower:] [:upper:])
	echo "============================= $TYPE =========================" >>$SUMMARY
	# paste <(cut -d ',' -f 1,3,4 ${FILES[0]}) >$tmp
	# cut -d ',' -f 1,3,4,5 ${FILES[0]} >$tmp
	awk -F ',' '{printf "%s,%s,%s,%s\n", $1,$3,$4,$5}' $METRICS_DIR/${SAMPLES[0]}/${SAMPLES[0]}.$suff >$tmp
	for sample in ${SAMPLES[@]:1}; do
		paste -d "," $tmp <(awk -F "," '{printf "%s,%s\n", $4,$5}' $METRICS_DIR/$sample/$sample.$suff) >${tmp}.1
		mv ${tmp}.1 $tmp
	done
	cat $tmp >>$SUMMARY
done
rm $tmp
# make single sample metrics
for sample in ${SAMPLES[@]}; do
	summary="$TSO500_OUTDIR/Results/${sample}/${sample}_AlignCollapseFusionCaller_metrics.csv"
	echo "Sample_ID,Percentage (%),${sample},%" >$summary
	for suff in ${SUFFIX[@]}; do
	        TYPE=$(basename $suff .csv)
        	TYPE=$(echo $TYPE|tr [:lower:] [:upper:])
	        echo "============================= $TYPE =========================" >>$summary
		awk -F ',' '{printf "%s,%s,%s,%s\n", $1,$3,$4,$5}' $METRICS_DIR/${SAMPLES[0]}/${SAMPLES[0]}.$suff >>$summary
	done
done


