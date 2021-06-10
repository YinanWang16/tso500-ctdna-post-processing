#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

# Extentions
$namespaces:
  s: https://schema.org/
  ilmn-tes: https://platform.illumina/rdf/ica/
# Metadata
s:author:
  - class: s:Person
    s:name: Yinan Wang
    s:email: mailto:ywang16@illumina.com

# label/doc
id: TSO500-post-processing
label: TSO500-post-processing
doc: |
  This workflow is designed according UMCCR's requirements to
  1. Convert file format;
  2. Backup files for archive;
  3. Upload files to PierianDx S3 (optional);
  4. Summarize DRAGEN metrics;
  5. Compress and index VCFs.

inputs:
  tso500-output-dir:
    label: tso500-output-dir:
    doc: Path to tso500 analysis output directory, in which 'Log_intermediates'
    and 'Results' are located.
    In ICA, it should be gds://path/to/tso500-analysis-output/wrn.xxx/GatheredResults
    type: Directory

outputs:
  reorginazed-tso500-output:
    label: reoriganized-tso500-output
    type: Directory

# about the code
s:dateCreated: 2021-06-09
s:codeRepository: https://github.com/YinanWang16/tso500-ctdna-post-processin
