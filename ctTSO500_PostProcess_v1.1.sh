#!/usr/bin/env	bash
# This script is to post-process TSO500 ctDNA output, which including:
# 1. lift-over VCF from hg19 to hg38 and make TMB_trace.vcf;
# 2. generate Faild_Exon_coverage_QC.txt
# Author: Yinan Wang (ywang16@illumina.com)
# Date: Fri Jan  8 10:31:58 AEDT 2021


## =============== Settings =============== ##
DOCKER_IMG_LIFTOVER=yinanwang16/tso500-liftover:1.0.3
DOCKER_IMG_MOSDEPTH=quay.io/biocontainers/mosdepth:0.3.1--ha7ba039_0
DOCKER_IMG_HTSLIB=miguelpmachado/htslib:1.9
CHAIN_RESOURCES=/staging/yinan/chain_resources/hg19_to_hg38
TSO500_MANIFEST_BED=/staging/illumina/DRAGEN_TSO500_ctDNA/resources/TST500C_manifest.bed
## ======================================== ##

# =============== Help page ============== ##
USAGE="Usage: $0 -d <FULL_PATH_TO_TSO500_OUTPUT> -h -v"
VERSION=1.1
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

## ============= Executionn =============== ##
log_file=$TSO500_OUTDIR/Results/post_process.log
touch $log_file
NOW="date --iso-8601=seconds"
# get sample list
SAMPLES=(`jq -r '.samples[].identifier' $TSO500_OUTDIR/Results/dsdm.json`)
EXECUTION_DIR=$(dirname $0)
#: <<'=cut'
## ---------- 1. Liftover -------------- ##
LIFTOVER_OUTDIR=$TSO500_OUTDIR/Results_VCF_hg38
if [ ! -f $LIFTOVER_OUTDIR ]; then
	mkdir -p $LIFTOVER_OUTDIR
fi
CMD="docker run --rm -u $UID \
	--mount type=bind,source=$TSO500_OUTDIR/Results,target=/mount/tso500_results \
	--mount type=bind,source=$CHAIN_RESOURCES,target=/mount/chain_resources \
	--mount type=bind,source=$LIFTOVER_OUTDIR,target=/mount/tso500_results_liftover \
	$DOCKER_IMG_LIFTOVER \
	/app/src/tso500_vcf_add_tag_and_liftover.sh -d /mount/tso500_results -r /mount/chain_resources -o /mount/tso500_results_liftover"
echo "@`$NOW`	$CMD" | tee -a $log_file
eval $CMD
for sample in ${SAMPLES[@]}; do
	docker run --rm -u $UID \
		--mount type=bind,source=$LIFTOVER_OUTDIR/${sample}_liftover,target=/mount/Results/sample \
		miguelpmachado/htslib:1.9 \
		bash -c 'cd /mount/Results/sample; for vcf in `find ./ -name "*vcf"`; do bgzip $vcf ; tabix -f ${vcf}.gz; done'
done
#=cut
## ---------- 2. Generate coverage QC file -------- ##
COVERAGE_OUTDIR=$TSO500_OUTDIR/Results_coverage_QC_intermediates
if [ ! -f $COVERAGE_OUTDIR ]; then
	mkdir -p $COVERAGE_OUTDIR
fi

# step 1. make coverage file using mosdepth
for sample in ${SAMPLES[@]}; do
#: <<'=cut'
	bam=$TSO500_OUTDIR/Logs_Intermediates/AlignCollapseFusionCaller/${sample}/${sample}.bam	# raw alignment is used here
	CMD="docker run --rm -u $UID \
        --mount type=bind,source=$bam,target=/mount/bam/${sample}.bam \
        --mount type=bind,source=${bam}.bai,target=/mount/bam/${sample}.bam.bai \
        --mount type=bind,source=$COVERAGE_OUTDIR,target=/mount/coverage_QC \
        --mount type=bind,source=$TSO500_MANIFEST_BED,target=/mount/bed/TST500C_manifest.bed \
        $DOCKER_IMG_MOSDEPTH \
        mosdepth -t 4 -b /mount/bed/TST500C_manifest.bed -T 100,250,500,750,1000,1500,2000,2500,3000,4000,5000,8000,10000 -n /mount/coverage_QC/$sample /mount/bam/${sample}.bam"
        echo "@`$NOW`	$CMD" | tee -a $log_file
        eval $CMD
	cat $COVERAGE_OUTDIR/mosdepth.log >>$log_file
#=cut
	# make the target region coverage metrics
	bed=$COVERAGE_OUTDIR/${sample}.thresholds.bed.gz
	tsv=$TSO500_OUTDIR/Results/${sample}/${sample}_TargetRegionCoverage.metrics.tsv
	CMD="EXECUTION_DIR/target_region_coverage_metrics.py -i $bed -o $tsv"
	echo "@`$NOW`	$CMD" | tee -a $log_file
	eval $CMD
#: <<'=cut'
# step 2. process mosdepth output threshold.bed.gz to generate Failed_Exon_coverage_QC.txt
	output=$TSO500_OUTDIR/Results/${sample}/${sample}_Failed_Exon_coverage_QC.txt
	# print header to the coverage QC file
	echo "Level 2: 100x coverage for > 50% of positions was not achieved for the targeted exon regions listed below:" > $output
	echo -e "index\tgene\ttranscript_acc\texon_id\tGE100\tGE250" >> $output
	# print header to the coverage QC file
	zcat $bed | \
	awk 'FNR > 1 {
        	LEN = $3-$2;
	        PCT100 = $5/LEN*100;
        	PCT250 = $6/LEN*100;
	        split($4, a, "_");
        	gsub(/[[:alpha:]]/, "", a[2]);
	        if (PCT100 < 50 && a[3] ~ /^NM/)
        		{printf "%d\t%s\t%s\t%d\t%.1f\t%.1f\n", FNR-1, a[1], a[3], a[2], PCT100, PCT250}
	    }' >> $output
#=cut
done
## ------------- 3. backup intermediate file to Resules ---------------- ##
## step 0. back up run.log to Results
cp $TSO500_OUTDIR/run.log $TSO500_OUTDIR/Results/run.log
# make Tmb and Msi folder in Results
mkdir -p $TSO500_OUTDIR/Results/Tmb $TSO500_OUTDIR/Results/Msi
# back up each sample
for sample in ${SAMPLES[@]}; do
	echo "@`$NOW`	backup intermediate file of $sample" | tee -a $log_file

## step 1. backup raw alignment BAM to Results
	raw_bam=$TSO500_OUTDIR/Logs_Intermediates/AlignCollapseFusionCaller/${sample}/${sample}.bam
	bak_raw_bam=$TSO500_OUTDIR/Results/${sample}/${sample}.bam
	cp $raw_bam $bak_raw_bam
	cp ${raw_bam}.bai ${bak_raw_bam}.bai
	cp ${raw_bam}.md5sum ${bak_raw_bam}md5sum

## step 2. backup evidence alignment BAM to Results
	evidence_bam=$TSO500_OUTDIR/Logs_Intermediates/AlignCollapseFusionCaller/${sample}/evidence.${sample}.bam
	bak_evidence_bam=$TSO500_OUTDIR/Results/${sample}/evidence.${sample}.bam
	cp $evidence_bam $bak_evidence_bam
	cp ${evidence_bam}.bai ${bak_evidence_bam}.bai

## step 3. backup cleaned.stitched BAM to Results
	cleaned_stitched_bam=$TSO500_OUTDIR/Logs_Intermediates/VariantCaller/${sample}/${sample}.cleaned.stitched.bam
	bak_cleaned_stitched_bam=$TSO500_OUTDIR/Results/${sample}/${sample}.cleaned.stitched.bam
	cp $cleaned_stitched_bam $bak_cleaned_stitched_bam
	cp ${cleaned_stitched_bam}.bai ${bak_cleaned_stitched_bam}.bai

## step 4. bgzip and tabix VCF files
	docker run --rm -u $UID \
		--mount type=bind,source=$TSO500_OUTDIR/Results/${sample},target=/mount/Results/sample \
		miguelpmachado/htslib:1.9 \
		bash -c 'cd /mount/Results/sample; for vcf in `find ./ -name "*vcf"`; do bgzip -c $vcf >${vcf}.gz; tabix -f ${vcf}.gz; done; rm '${sample}'_MergedSmallVariants.genome.vcf'

## step 4. back up TMB and MSI json to Results
	tmb_json=$TSO500_OUTDIR/Logs_Intermediates/Tmb/${sample}/${sample}.tmb.json
	bak_tmb_json=$TSO500_OUTDIR/Results/${sample}/${sample}.tmb.json
	cp $tmb_json $bak_tmb_json

	msi_json=$TSO500_OUTDIR/Logs_Intermediates/Msi/${sample}/${sample}.msi.json
	bak_msi_json=$TSO500_OUTDIR/Results/${sample}/${sample}.msi.json
	cp $msi_json $bak_msi_json
done
## ----------------- 4. generate conbined DRAGEN QC metrics ---------------------- ##
COMBINE=/staging/yinan/script/combine_AlignCollapseFusionCaller_metrics.sh
echo "@`$NOW`	Making combined DRAGEN QC metrics" | tee -a $log_file
$EXECUTION_DIR/combine_AlignCollapseFusionCaller_metrics.sh -d $TSO500_OUTDIR

## ----------------- 5. split MetricsOutput.tsv to sample subdir ----------------- ##
CMD="perl $EXECUTION_DIR/split_MetricsOutput.tsv.pl $TSO500_OUTDIR/Results/MetricsOutput.tsv"
echo "@`$NOW`  Splitting MetricsOutput.tsv" | tee -a $log_file
eval $CMD
echo "@`$NOW`	Finished" | tee -a $log_file
## ======================= END of Execution ============================ ##
