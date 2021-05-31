#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# Extentions
$namespaces:
  s: https://schema.org/
# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

# label/doc
id: make_target_region_coverage_metrics
label: parse 'threshold.bed' to make target region coverage metrics
doc: |
  from mosdepth output 'thresholds.bed.gz' make consensus reads coverage metrics
  on target regions.

# about the code
s:dateCreated: 2021-05-31
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processing

requirements:
  DockerRequirement:
    dockerPull: umccr/alpine_pandas:latest-cwl
  InitialWorkDirRequirement:
    listing:
      - entryname: target_region_coverage_metrics.py
        entry: |
          #!/usr/bin/env python3

          import pandas as pd
          from os import path
          import argparse

          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='From mosdepth threshold.bed to make target_region_coverage_metrics.csv')

              # add arguments
              parser.add_argument('-i', '--input-bed', required=True,
                                  help='Mosdepth output file "threshold.bed", ungzipped')

          def main():
              """ Calculate consensus reads coverage metrics """
              args = get_args()
              threshold_bed = args.input_bed
              sample_id = path.basname(threshold_bed).split('.')[0]
              output_csv = sample_id + '_TargetRegionCoverage.csv'

              # open threshold.bed file and load to dataframe
              with open(threshold_bed, 'rt') as i:
                  data = pd.read_csv(i, sep='\t', header=0)
              # calculate total legnth of targeted region
              lenth_sum = pd.DataFrame.sum(data['end'] = data['start'])
              # write results to file
              with open(output_csv, 'w') as o:
                  o.write('ConsensusReadDepth\tBasePair\tPercentage\n')
                  o.write('TargetRegion\t' + str(length_sum) + '\t100%\n')
                  for col in data.columns[4:]:
                      threshold_pass_nt = pd.DataFrame.sum(data[col])
                      percentage = format(threshold_pass_nt * 100 / length_sum, '.2f')
                      o.write(col + '\t' + str(threshold_pass_nt) + '\t' +  str(percentage) + '%' + '\n')
          main()

baseCommand: ["python3", "target_region_coverage_metrics.py"]

inputs:
  thresholds_bed:
    type: File
    inputBinding:
      position: 0
  sample_id:
    type: string
outputs:
  target_region_coverage_metrics:
    type: File
    outputBinding:
      glob: "$(inputs.sample_id.basename)_TargetRegionCoverage.csv"
