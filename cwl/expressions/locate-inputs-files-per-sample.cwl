#!/usr/bin/env cwl-runner

cwlVersion: v1.1
class: ExpressionTool

doc:
  Given tso500-ctDNA-analysis-output-dir and Sample_ID,
  locate all the files needed for post-processing.

requirements:
  - class: InlineJavascriptRequirement
    expressionLib:
      - var raw_bam_file = function() {
          return inputs.tso500_ctdna_output_dir.basename + "/Logs_Intermediates/AlignCollapseFusionCaller/" + inputs.sample_id + "/" + inputs.sample_id + ".bam";
        }

inputs:
  tso500_ctdna_output_dir:
    type: Directory
  sample_id:
    type: string

expression: |
  ${
    file_list = inputs.tso500_ctdna_output_dir.listing;
    var IntermediatesDir = inputs.tso500_ctdna_output_dir.basename + "/Logs_Intermediates/";
    var ACFCPrefix = IntermediatesDir + "AlignCollapseFusionCaller/" + inputs.sample_id + "/" + inputs.sample_id;
    var MsiPrefix = IntermediatesDir + "Msi/" + inputs.sample_id + "/" + inputs.sample_id;
    var TmbPrefix = IntermediatesDir + "Tmb/" + inputs.sample_id + "/" + inputs.sample_id;
    var SARPrefix = IntermediatesDir + "SampleAnalysisResults/" + inputs.sample_id + "/" + inputs.sample_id;
    var VCPrefix = IntermediatesDir + "VariantCaller/" + inputs.sample_id + "/" + inputs.sample_id;
    var ResultsPrefix = inputs.tso500_ctdna_output_dir.basename + "/Results/" + inputs.sample_id + "/" + inputs.sample_id;
    var raw_bam_file = ACFCPrefix + ".bam";
    var raw_bam_md5sum_file = ACFCPrefix + ".bam.md5sum";
    var evidence_bam_file = IntermediatesDir + "AlignCollapseFusionCaller/" + inputs.sample_id + "/evidence." + inputs.sample_id + ".bam";
    var evidence_bai_file = IntermediatesDir + "AlignCollapseFusionCaller/" + inputs.sample_id + "/evidence." + inputs.sample_id + ".bam.bai";
    var mapping_metrics_csv_file = ACFCPrefix + ".mapping_metrics.csv";
    var trimmer_metrics_csv_file = ACFCPrefix + ".trimmer_metrics.csv";
    var umi_metrics_csv_file = ACFCPrefix + ".umi_metrics.csv";
    var wgs_coverage_metrics_csv_file = ACFCPrefix + ".wgs_coverage_metrics.csv";
    var sv_metrics_csv_file = ACFCPrefix + ".sv_metrics.csv";
    var time_metrics_csv_file = ACFCPrefix + ".time_metrics.csv";
    var fragment_length_hist_csv_file = ACFCPrefix + ".fragment_length_hist.csv";
    return {
      "raw_bam": 
      "raw_bam_md5sum": raw_bam_md5sum_file,
      "evidence_bam": evidence_bam_file,
      "evidence_bai": evidence_bai_file,
      "mapping_metrics_csv": mapping_metrics_csv_file,
      "trimmer_metrics_csv": trimmer_metrics_csv_file,
      "umi_metrics_csv": umi_metrics_csv_file,
      "wgs_coverage_metrics_csv": wgs_coverage_metrics_csv_file,
      "sv_metrics_csv": sv_metrics_csv_file,
      "time_metrics_csv": time_metrics_csv_file,
      "fragment_length_hist_csv": fragment_length_hist_csv_file
    }
  }

outputs:
  raw_bam:
    type: File
    secondaryFiles: .bai
  raw_bai:
    type: File
  raw_bam_md5sum:
    type: File
  evidence_bam:
    type: File
  evidence_bai:
    type: File
  mapping_metrics_csv:
    type: File
  trimmer_metrics_csv:
    type: File
  umi_metrics_csv:
    type: File
  wgs_coverage_metrics_csv:
    type: File
  sv_metrics_csv:
    type: File
  time_metrics_csv:
    type: File
  fragment_length_hist_csv:
    type: File
