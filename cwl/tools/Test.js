var dsdm_contents = '{ "samples": [ { "identifier": "Seraseq_Comp_Mut_Mix_AF1_DNA_rep1", "qualified": true, "stepsToRun": [ "AlignCollapseFusionCaller", "Annotation", "Cleanup", "CnvCaller", "CombinedVariantOutput", "Contamination", "DnaFusionFiltering", "DnaQCMetrics", "FastqGeneration", "FastqValidation", "MaxSomaticVaf", "MergedAnnotation", "MetricsOutput", "Msi", "PhasedVariants", "ResourceVerification", "RunQc", "SampleAnalysisResults", "SamplesheetValidation", "SmallVariantFilter", "StitchedRealigned", "Tmb", "VariantCaller", "VariantMatching" ], "executedAndPassed": [ "AlignCollapseFusionCaller", "Annotation", "CnvCaller", "CombinedVariantOutput", "Contamination", "DnaFusionFiltering", "DnaQCMetrics", "FastqGeneration", "FastqValidation", "MaxSomaticVaf", "MergedAnnotation", "MetricsOutput", "Msi", "PhasedVariants", "ResourceVerification", "RunQc", "SampleAnalysisResults", "SamplesheetValidation", "SmallVariantFilter", "StitchedRealigned", "Tmb", "VariantCaller", "VariantMatching" ], "executedAndFailed": [], "didNotExecute": [] } ]}';
let reader = new FileReader()
var dsdmJson = "/data/staging/ywang16_test/Projects/tso500-ctdna-post-processing/example_data/200212_A00807_0128_AH5CWWDSXY_analysis/Results/dsdm.json";
dsdm_contents = readAsText(dsdmJson);
var dsdmObj = JSON.parse(dsdm_contents);
var sample_id_list = [];
for (var i = 0; i < dsdmObj.samples.length; i++) {
  if (dsdmObj.samples[i].qualified) {
    sample_id_list.push(dsdmObj.samples[i].identifier);
  }
}
console.log(sample_id_list)
