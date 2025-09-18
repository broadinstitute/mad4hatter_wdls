version 1.0

task pre_process_coverage {
  input {
    Array[File] sample_coverages
    Array[File] amplicon_coverages
  }

  # TODO: Fill in docker image here when available
  String docker_image = ""

  command <<<
  set -euo pipefail

  add_sample_name_column() {
    awk -v fname=\$(basename "\$1" | sed -e 's/.SAMPLEsummary.txt//g' -e 's/.AMPLICONsummary.txt//g') -v OFS="\\t" '{print fname, \$0}' "\$1"
  }

  echo -e "SampleID\\tStage\\tReads" > sample_coverage.txt
  echo -e "SampleID\\tLocus\\tReads" > amplicon_coverage.txt

  for file in $sample_coverages
  do
      add_sample_name_column \$file >> sample_coverage.txt
  done

  for file in $amplicon_coverages
  do
      add_sample_name_column \$file >> amplicon_coverage.txt
  done

  >>>

  output {
    File sample_coverage = "sample_coverage.txt"
    File amplicon_coverage = "amplicon_coverage.txt"
  }

  runtime {
      docker: docker_image
      memory: "8G"
  }

}