#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: ExpressionTool

doc: |
  Retrieve a list of file objects from a directory.
label: discover_files_from_directory

requirements:
  - class: LoadListingRequirement
    loadListing: shallow_listing
  - class: InlineJavascriptRequirement
    expressionLib:
      - var find_file_from_dir = function (dir, file_name_list) {
          var output_list = [];
          var l = dir.listing;
          var n = l.length;
          for (var i = 0; i < n; i++) {
            if (l[i].class === "File") {
              file_name_list.forEach(function (item, index) {
                if (item === l[i].basename) {
                  output_list.push(l[i]);
                  file_name_list.splice(index, 1);
                }
              } )
            }
            if (file_name_list.length == 0) {
              break;
            }
          };
          return output_list;}

inputs:
  input_dir:
    type: Directory
    doc: |
      Input directory to finding files
  file_basename_list:
    type: string[]
    doc: |
      List of the files names to find from the input_dir

outputs:
  output_files:
    type: File[]
    doc: |
      List of file objects extracted from the input directory

expression: >-
  ${
    return {"output_files": find_file_from_dir(inputs.input_dir, inputs.file_basename_list)};
  }
