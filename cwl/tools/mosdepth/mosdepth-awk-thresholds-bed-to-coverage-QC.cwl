#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
id: awk
label: awk
doc: |
    awk parse thresholds.bed to make {sample}_Failed_Exon_coverage_QC.txt
requirements:
  InlineJavascriptRequirement: {}

baseCommand:
  - awk
  - 'FNR > 1 {
                LEN = $3-$2;
                PCT100 = $5/LEN*100;
                PCT250 = $6/LEN*100;
                split($4, a, "_");
                gsub(/[[:alpha:]]/, "", a[2]);
                if (PCT100 < 50 && a[3] ~ /^NM/) {
                    printf "%s\t%s\t%s\t%d\t%.1f\t%.1f\n", $4, a[1], a[3], a[2], PCT100, PCT250
                }
            }'
inputs:
  thresholds_bed:
    type: File
    inputBinding:
      position: 0

stdout:
  $(inputs.thresholds_bed.nameroot.split('.')[0]).coverage_QC
outputs:
  coverage_QC:
    type: stdout
