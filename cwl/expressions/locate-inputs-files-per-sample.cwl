#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool

doc:
  Given tso500-ctDNA-analysis-output-dir and Sample_ID,
  locate all the files needed for post-processing.

requirements:
  - class: InlineJavascriptRequirement

inputs:
  tso500_ctdna_output_dir:
    type: Directory
  sample_id:
    type: string

expression: >-
  ${
    var raw_bam_file = '';
    var raw_bai_file = '';
    var raw_bam_md5sum_file = '';
    var evidence_bam_file = '';
    var evidence_bai_file = '';
    var mapping_metrics_csv_file = '';
    var trimmer_metrics_csv_file = '';
    var umi_metrics_csv_file = '';
    var wgs_coverage_metrics_csv_file = '';
    var sv_metrics_csv_file = '';
    var time_metrics_csv_file = '';
    var fragment_length_hist_csv_file = '';
    var msi_json_file = '';
    var sampleanalysisresults_json_file = '';
    var tmb_json_file = '';
    var cleaned_stitched_bam_file = '';
    var cleaned_stitched_bai_file = '';
    var vcf_files = [];
    var fusion_csv_file = '';
    var mergedsmallvariantsannotated_json_gz_file = '';
    var tmb_trace_tsv_file = '';
    inputs.tso500_ctdna_output_dir.listing.forEach(function (item) {
      if (item.class == "Directory" && item.basename === "Logs_Intermediates") {
        item.listing.forEach(function (item2) {
          if (item2.class == "Directory" && item2.basename === "AlignCollapseFusionCaller") {
            item2.listing.forEach(function (item3) {
              if (item3.class == "Directory" && item3.basename === inputs.sample_id) {
                item3.listing.forEach(function (item4) {
                  if (item4.basename === inputs.sample_id + ".bam") {
                    raw_bam_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".bam.bai") {
                    raw_bai_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".bam.md5sum") {
                    raw_bam_md5sum_file = item4;
                  } else if (item4.basename === "evidence." + inputs.sample_id + ".bam") {
                    evidence_bam_file = item4;
                  } else if (item4.basename === "evidence." + inputs.sample_id + ".bam.bai") {
                    evidence_bai_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".mapping_metrics.csv") {
                    mapping_metrics_csv_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".trimmer_metrics.csv") {
                    trimmer_metrics_csv_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".umi_metrics.csv") {
                    umi_metrics_csv_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".wgs_coverage_metrics.csv") {
                    wgs_coverage_metrics_csv_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".sv_metrics.csv") {
                    sv_metrics_csv_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".time_metrics.csv") {
                    time_metrics_csv_file = item4;
                  } else if (item4.basename === inputs.sample_id + ".fragment_length_hist.csv") {
                    fragment_length_hist_csv_file = item4;
                  }
                })
              }
            })
          } else if (item2.class == "Directory" && item2.basename === "Msi") {
            item2.listing.forEach(function (item3) {
              if (item3.class == "Directory" && item3.basename === inputs.sample_id) {
                item3.listing.forEach(function (item4) {
                  if (item4.basename === inputs.sample_id + ".msi.json") {
                    msi_json_file = item4;
                  }
                })
              }
            })
          } else if (item2.class == "Directory" && item2.basename === "SampleAnalysisResults") {
            item2.listing.forEach(function (item3) {
              if (item3.class == "Directory" && item3.basename === inputs.sample_id) {
                item3.listing.forEach(function (item4) {
                  if (item4.basename === inputs.sample_id + "SampleAnalysisResults.json") {
                    sampleanalysisresults_json_file = item4;
                  }
                })
              }
            })
          } else if (item2.class == "Directory" && item2.basename === "Tmb") {
            item2.listing.forEach(function (item3) {
              if (item3.class == "Directory" && item3.basename === inputs.sample_id) {
                item3.listing.forEach(function (item4) {
                  if (item4.basename === inputs.sample_id + "tmb.json") {
                    tmb_json_file = item4;
                  }
                })
              }
            })
          } else if (item2.class == "Directory" && item2.basename === "VariantCaller") {
            item2.listing.forEach(function (item3) {
              if (item3.class == "Directory" && item3.basename === inputs.sample_id) {
                item3.listing.forEach(function (item4) {
                  if (item4.basename === inputs.sample_id + "cleaned.stitched.bam") {
                    cleaned_stitched_bam_file = item4;
                  } else if (item4.basename === inputs.sample_id + "cleaned.stitched.bam.bai") {
                    cleaned_stitched_bai_file = item4;
                  }
                })
              }
            })
          }
        })
      } else if (item.class == "Directory" && item.basename === "Results") {
        item.listing.forEach(function (item2) {
          if (item2.class == "Directory" && item2.basename === inputs.sample_id) {
            item2.listing.forEach(function (item3) {
              if (item3.basename.endsWith(".vcf")) {
                vcf_files.push(item3);
              } else if (item3.basename === inputs.sample_id + "_Fusion.csv"){
                fusion_csv_file = item3;
              } else if (item3.basename === inputs.sample_id + "_MergedSmallVariantsAnnotated.json.gz") {
                mergedsmallvariantsannotated_json_gz_file = item3;
              } else if (item3.basename === inputs.sample_id + "_TMB_Trace.tsv") {
                tmb_trace_tsv_file = item3;
              }
            })
          }
        })
      }
    })
    return {
      "raw_bam": raw_bam_file,
      "raw_bai": raw_bai_file,
      "raw_bam_md5sum": raw_bam_md5sum_file,
      "evidence_bam": evidence_bam_file,
      "evidence_bai": evidence_bai_file,
      "mapping_metrics_csv": mapping_metrics_csv_file,
      "trimmer_metrics_csv": trimmer_metrics_csv_file,
      "umi_metrics_csv": umi_metrics_csv_file,
      "wgs_coverage_metrics_csv": wgs_coverage_metrics_csv_file,
      "sv_metrics_csv": sv_metrics_csv_file,
      "time_metrics_csv": time_metrics_csv_file,
      "fragment_length_hist_csv": fragment_length_hist_csv_file,
      "msi_json": msi_json_file,
      "sampleanalysisresults_json": sampleanalysisresults_json_file,
      "tmb_json": tmb_json_file,
      "cleaned_stitched_bam": cleaned_stitched_bam_file,
      "cleaned_stitched_bai": cleaned_stitched_bai_file,
      "vcfs" = vcf_files,
      "fusion_csv" = fusion_csv_file,
      "mergedsmallvariantsannotated_json_gz" = mergedsmallvariantsannotated_json_gz_file,
      "tmb_trace_tsv" = tmb_trace_tsv_file
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
  msi_json:
    type: File
  sampleanalysisresults_json:
    type: File
  cleaned_stitched_bam:
    type: File
  cleaned_stitched_bai:
    type: File
  vcfs:
    type: File[]
  fusion_vcf:
    type: File
  mergedsmallvariantsannotated_json_gz:
    type: File
  tmb_trace_tsv:
    type: File
