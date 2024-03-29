#!/usr/bin/env cwl-runner
cwlVersion: v1.1
class: CommandLineTool

# Extentions
$namespaces:
  ilmn-tes: https://platform.illumina/rdf/ica/

# label/doc
id: make_target_region_coverage_metrics
label: target_region_coverage_metrics.py
doc: |
  from mosdepth output 'thresholds.bed.gz' to make consensus reads coverage metrics
  on target regions.

hints:
  DockerRequirement:
    dockerPull: umccr/alpine_pandas:latest-cwl
  ResourceRequirement:
    ilmn-tes:resources:
      tier: standard
      type: standard
      size: small

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: target_region_coverage_metrics.py
        entry: |
          #!/usr/bin/env python3

          import pandas as pd
          from os import path
          import argparse
          import gzip

          def get_args():
              """ Get arguments for the command """
              parser = argparse.ArgumentParser(description='From mosdepth threshold.bed to make consensus reads coverage on target region (TargetRegionCoverage.tsv)')

              # add arguments
              parser.add_argument('-i', '--input-bed', required=True,
                                  help='Mosdepth output file "threshold.bed.gz"')

              parser.add_argument('-p', '--prefix', required=False,
                                  help='prefix of output TargetRegionCoverage.tsv')
              return parser.parse_args()

          def main():
              """ Calculate consensus reads coverage metrics """
              args = get_args()
              # thresholds_bed = args.input_bed
              # sample_id = path.basename(thresholds_bed).split('.')[0]
              if args.prefix:
                  output_tsv = args.prefix + '.TargetRegionCoverage.tsv'
              else:
                  output_tsv = path.basename(args.input_bed).split('.')[0] + '.TargetRegionCoverage.tsv'

              # open threshold.bed file and load to dataframe
              with gzip.open(args.input_bed, 'rt') as i:
                  data = pd.read_csv(i, sep='\t', header=0)
              # calculate total legnth of targeted region
              length_sum = pd.DataFrame.sum(data['end'] - data['start'])
              # write results to file
              with open(output_tsv, 'w') as o:
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
    label: thresholds.bed.gz
    doc: mosdepth output thresholds.bed.gz
    inputBinding:
      prefix: -i
      position: 0
  sample_id:
    type: string?
    inputBinding:
      prefix: -p
      position: 1
outputs:
  target_region_coverage_metrics:
    type: File
    outputBinding:
      glob: "$(inputs.thresholds_bed.nameroot.split('.')[0]).TargetRegionCoverage.tsv"
