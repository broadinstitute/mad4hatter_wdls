version 1.0

task preprocess_coverage {
  input {
    Array[File] sample_coverages
    Array[File] amplicon_coverages
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
  set -euo pipefail

  add_sample_name_column() {
      fname=$(basename "$1" | sed -e 's/.SAMPLEsummary.txt//g' -e 's/.AMPLICONsummary.txt//g')
      awk -v fname="$fname" -v OFS="\t" '{print fname, $0}' "$1"
  }

  echo -e "SampleID\\tStage\\tReads" > sample_coverage.txt
  echo -e "SampleID\\tLocus\\tReads" > amplicon_coverage.txt

  for file in ~{sep=" " sample_coverages}
  do
      echo "Processing $file" >&2
      add_sample_name_column $file >> sample_coverage.txt
  done

  for file in ~{sep=" " amplicon_coverages}
  do
      echo "Processing $file" >&2
      add_sample_name_column $file >> amplicon_coverage.txt
  done

  >>>

  output {
    File sample_coverage = "sample_coverage.txt"
    File amplicon_coverage = "amplicon_coverage.txt"
  }

  runtime {
      docker: docker_image
      #TODO: Should we hardcode this?
      memory: "8G"
  }

}