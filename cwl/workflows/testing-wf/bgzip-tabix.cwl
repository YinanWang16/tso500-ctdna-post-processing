#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  vcf_files: File[]

outputs:
  vcf_gz_files:
    type: File[]
    outputSource: bgzip/vcf_gz
  tbi_files:
    type: File[]
    outputSource: tabix/tbi

steps:
  bgzip:
    run: ../tools/bgzip-vcf.cwl
    label: bgzip
    in:
      vcf: vcf_files
    out: [vcf_gz]
    scatter: vcf
  tabix:
    run: ../tools/tabix-vcf.cwl
    label: tabix
    in:
      vcf_gz: bgzip/vcf_gz
    out: [tbi]
    scatter: vcf_gz
