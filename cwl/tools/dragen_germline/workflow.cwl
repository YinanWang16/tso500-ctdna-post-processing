!!com.bluebee.core.genomics.cwl.io.workflowcwl.v1.IlluminaCWLWorkflow
$namespaces:
  bb: http://bluebee.com/cwl/
$schemas:
- /usr/local/bb-toil/bb-schemas/bb.rdf
bb:interpreterVersion: '2.0'
class: Workflow
cwlVersion: v1.0
label: "DRAGEN 3.8.4 \n\nThe DRAGEN Germline tool aligns and optionally variant calls\
  \ from FASTQ or BAM inputs.  Multiple samples can be provided to run all samples\
  \ in batch mode on a single node."
doc: This is a run of machineprofile null of pipeline DRAGEN Germline Built-In License
  1.3.0
id: DRAGEN_Germline_Built-In_License_1.3.0
requirements:
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
inputs:
  QC_Coverage_Regions_BEDs:
    type:
    - File[]
    - 'null'
  Panel_of_Normals_TAR:
    type:
    - File
    - 'null'
  Reference:
    type: File
  DRAGEN_Germline_Built-In_License__enable_cnv:
    type: string?
  DRAGEN_Germline_Built-In_License__cnv_enable_self_normalization:
    type: string?
  DRAGEN_Germline_Built-In_License__additional_args:
    type: string?
  DRAGEN_Germline_Built-In_License__output_format:
    type: string?
  DRAGEN_Germline_Built-In_License__enable_map_align:
    type: string?
  DRAGEN_Germline_Built-In_License__enable_map_align_output:
    type: string?
  FASTQ_Files:
    type:
    - File[]
    - 'null'
  DRAGEN_Germline_Built-In_License__enable_variant_caller:
    type: string?
  DRAGEN_Germline_Built-In_License__enable_duplicate_marking:
    type: string?
  Panel_of_Normals_Files:
    type:
    - File[]
    - 'null'
  DRAGEN_Germline_Built-In_License__enable_sv:
    type: string?
  DRAGEN_Germline_Built-In_License__vc_emit_ref_confidence:
    type: string?
  DRAGEN_Germline_Built-In_License__repeat_genotype_enable:
    type: string?
  DRAGEN_Germline_Built-In_License__sample_sex:
    type: string?
  BAM_Files:
    secondaryFiles:
    - .bai
    type:
    - File[]
    - 'null'
outputs:
  DRAGEN_Germline_Built-In_License__repeats_vcf_files:
    secondaryFiles:
    - .tbi
    outputSource: DRAGEN_Germline_Built-In_License/repeats_vcf_files
    type: File[]?
  DRAGEN_Germline_Built-In_License__small_var_gvcf_files:
    secondaryFiles:
    - .tbi
    outputSource: DRAGEN_Germline_Built-In_License/small_var_gvcf_files
    type: File[]?
  DRAGEN_Germline_Built-In_License__output_directory:
    outputSource: DRAGEN_Germline_Built-In_License/output_directory
    type: Directory
  DRAGEN_Germline_Built-In_License__cnv_vcf_files:
    secondaryFiles:
    - .tbi
    outputSource: DRAGEN_Germline_Built-In_License/cnv_vcf_files
    type: File[]?
  DRAGEN_Germline_Built-In_License__tn_tsvs:
    outputSource: DRAGEN_Germline_Built-In_License/tn_tsvs
    type: File[]?
  DRAGEN_Germline_Built-In_License__small_var_vcf_files:
    secondaryFiles:
    - .tbi
    outputSource: DRAGEN_Germline_Built-In_License/small_var_vcf_files
    type: File[]?
  DRAGEN_Germline_Built-In_License__bam_files:
    secondaryFiles:
    - .bai
    outputSource: DRAGEN_Germline_Built-In_License/bam_files
    type: File[]?
  DRAGEN_Germline_Built-In_License__sv_vcf_files:
    secondaryFiles:
    - .tbi
    outputSource: DRAGEN_Germline_Built-In_License/sv_vcf_files
    type: File[]?
steps:
  DRAGEN_Germline_Built-In_License:
    run: 2bbae530-f4ae-49d3-99cb-29c3448674b0.cwl
    in:
      qc_coverage_region_beds:
        source:
        - QC_Coverage_Regions_BEDs
      enable_variant_caller:
        source: DRAGEN_Germline_Built-In_License__enable_variant_caller
      fastqs:
        source:
        - FASTQ_Files
      enable_sv:
        source: DRAGEN_Germline_Built-In_License__enable_sv
      cnv_normals_tar: Panel_of_Normals_TAR
      repeat_genotype_enable:
        source: DRAGEN_Germline_Built-In_License__repeat_genotype_enable
      bams:
        source:
        - BAM_Files
      enable_map_align:
        source: DRAGEN_Germline_Built-In_License__enable_map_align
      reference: Reference
      enable_cnv:
        source: DRAGEN_Germline_Built-In_License__enable_cnv
      cnv_normals_files:
        source:
        - Panel_of_Normals_Files
      output_format:
        source: DRAGEN_Germline_Built-In_License__output_format
      cnv_enable_self_normalization:
        source: DRAGEN_Germline_Built-In_License__cnv_enable_self_normalization
      enable_duplicate_marking:
        source: DRAGEN_Germline_Built-In_License__enable_duplicate_marking
      vc_emit_ref_confidence:
        source: DRAGEN_Germline_Built-In_License__vc_emit_ref_confidence
      additional_args:
        source: DRAGEN_Germline_Built-In_License__additional_args
      sample_sex:
        source: DRAGEN_Germline_Built-In_License__sample_sex
      enable_map_align_output:
        source: DRAGEN_Germline_Built-In_License__enable_map_align_output
    out:
    - bam_files
    - small_var_vcf_files
    - small_var_gvcf_files
    - cnv_vcf_files
    - tn_tsvs
    - sv_vcf_files
    - repeats_vcf_files
    - output_directory
