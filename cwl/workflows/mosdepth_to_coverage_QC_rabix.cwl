class: Workflow
cwlVersion: v1.0
id: make_coverage__q_c
doc: >
  Input is mosdepth output 'threshold.bed.gz'.

  Outputs are 'Failed_Exon_coverage_QC.txt' and
  'target_region_coverage_metrics'.
label: make Failed_Exon_coverage_QC.txt for pierianDx CGW
$namespaces:
  s: 'https://schema.org/'
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: bam_file
    type: File
    label: raw_bam
    doc: The path to the raw alignment bam file
    secondaryFiles:
      - .bai
    'sbg:x': 60.07881164550781
    'sbg:y': 348.8055114746094
  - id: sample_id
    type: string
    'sbg:x': 58.00712585449219
    'sbg:y': 200.5695037841797
  - id: tso_manifest_bed
    type: File
    label: tso_manifest_bed
    doc: target region bed file
    'sbg:x': 55.93544387817383
    'sbg:y': 51.79207992553711
outputs:
  - id: exon_coverage_qc
    outputSource:
      - cat/coverage_QC_txt
    type: File
    label: Failed_Exon_coverage_QC.txt
    doc: For PierianDx CGW
    'sbg:x': 1239.0467529296875
    'sbg:y': 374.3201599121094
  - id: target_region_coverage_metrics
    outputSource:
      - coverage_metrics/target_region_coverage_metrics
    type: File
    label: TargetRegionCoverage.tsv
    doc: Consensus reads converage on TSO targeted regions.
    'sbg:x': 1233.5181884765625
    'sbg:y': 179.6607666015625
steps:
  - id: cat
    in:
      - id: coverage_QC_data
        source: coverage_QC/coverage_QC
      - id: header_txt
        source: echo/header_file
    out:
      - id: coverage_QC_txt
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      baseCommand:
        - cat
      inputs:
        - id: coverage_QC_data
          type: File
          inputBinding:
            position: 1
        - id: header_txt
          type: File
          inputBinding:
            position: 0
      outputs:
        - id: coverage_QC_txt
          type: stdout
      stdout: $(inputs.coverage_QC_data.nameroot)_Failed_Exon_coverage_QC.txt
      requirements:
        - class: InlineJavascriptRequirement
    'sbg:x': 1036.708251953125
    'sbg:y': 378.27166748046875
  - id: coverage_QC
    in:
      - id: sample_id
        source: sample_id
      - id: thresholds_bed
        source: gunzip/unzipped_file
    out:
      - id: coverage_QC
    run: ../tools/mk-awk-bed2coverage-QC.cwl
    label: awk
    'sbg:x': 770.6661376953125
    'sbg:y': 386.0306091308594
  - id: coverage_metrics
    in:
      - id: sample_id
        source: sample_id
      - id: thresholds_bed
        source: gunzip/unzipped_file
    out:
      - id: target_region_coverage_metrics
    run: ../tools/mk-target-region-coverage-metrics.cwl
    label: target_region_coverage_metrics.py
    'sbg:x': 793.6221923828125
    'sbg:y': 174.9895782470703
  - id: echo
    in: []
    out:
      - id: header_file
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      baseCommand:
        - bash
        - header.sh
      inputs: []
      outputs:
        - id: header_file
          type: stdout
      requirements:
        - class: InitialWorkDirRequirement
          listing:
            - entryname: header.sh
              entry: >
                echo -e "Level 2: 100x coverage for > 50% of positions was not
                achieved for the targeted exon regions listed below:"

                echo -e "index\tgene\ttranscript_acc\texon_id\tGE100\tGE250"
              writable: false
      stdout: header.txt
    'sbg:x': 870.1068725585938
    'sbg:y': 303.4339294433594
  - id: gunzip
    in:
      - id: gz_file
        source: mosdepth/thresholds_bed_gz
    out:
      - id: unzipped_file
    run: ../tools/gunzip.cwl
    label: gunzip
    'sbg:x': 530.4064331054688
    'sbg:y': 117.76740264892578
  - id: mosdepth
    in:
      - id: bam_or_cram
        source: bam_file
      - id: output_prefix
        source: sample_id
      - id: target_region_bed
        source: tso_manifest_bed
    out:
      - id: thresholds_bed_gz
    run: ../tools/mosdepth-thresholds-bed.cwl
    'sbg:x': 308.5842590332031
    'sbg:y': 120.34087371826172
requirements: []
's:author':
  - class: 's:Person'
    's:email': 'mailto:ywang16@illumina.com'
    's:name': Yinan Wang
's:codeRepository': 'https://github.com/YinanWang16/tso500-ctdna-post-processing'
