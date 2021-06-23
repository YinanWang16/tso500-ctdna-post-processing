#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
doc: |
  Transforms sample specific outputs to match the desired output

requirements:
  - class: InlineJavascriptRequirement
inputs:
  evidence_bam:
    type: File
  evidence_bai:
    type: File
  dragen_metrics_json:
    type: File
  raw_bam:
    type: File
  raw_bai:
    type: File
  raw_bam_md5sum:
    type: File
  cleaned_stitched_bam:
    type: File
  cleaned_stitched_bai:
    type: File
  copynumbervariants_vcf_gz:
    type: File
  copynumbervariants_vcf_tbi:
    type: File
  coverage_qc_json:
    type: File
  coverage_qc:
    type: File
  fusion_csv:
    type: File
  mergedsmallvariantsannotated_json:
    type: File
  mergedsmallvariants_genome_vcf_gz:
    type: File
  mergedsmallvariants_genome_vcf_tbi:
    type: File
  mergedsmallvariants_vcf_gz:
    type: File
  mergedsmallvariants_vcf_tbi:
    type: File
  msi_json:
    type: File
  sampleanalysisresults_json:
    type: File
  targetregioncoverage_metrics_json:
    type: File
  tmb_json:
    type: File
  tmb_trace_json:
    type: File
  fragment_length_hist_json:
    type: File
  sample_id:
    type: string

expression: |
  ${
    var r = {
      "outputs":
        { "class": "Directory",
          "basename": inputs.sample_id,
          "listing": [
            inputs.evidence_bam,
            inputs.evidence_bai,
            inputs.dragen_metrics_json,
            inputs.raw_bam,
            inputs.raw_bai,
            inputs.raw_bam_md5sum,
            inputs.cleaned_stitched_bam,
            inputs.cleaned_stitched_bai,
            inputs.copynumbervariants_vcf_gz,
            inputs.copynumbervariants_vcf_tbi,
            inputs.coverage_qc_json,
            inputs.coverage_qc,
            inputs.fusion_csv,
            inputs.mergedsmallvariantsannotated_json,
            inputs.mergedsmallvariants_genome_vcf_gz,
            inputs.mergedsmallvariants_genome_vcf_tbi,
            inputs.mergedsmallvariants_vcf_gz,
            inputs.mergedsmallvariants_vcf_tbi,
            inputs.msi_json,
            inputs.sampleanalysisresults_json,
            inputs.tmb_json,
            inputs.tmb_trace_json,
            inputs.fragment_length_hist_json ] }
    }
    return r;
  }

outputs:
  sample_results: Directory 
