version 1.0

task quality_report {
  input {
    File sample_coverage
    File amplicon_coverage
    File amplicon_info
  }

  # TODO: Fill in docker image here when available
  String docker_image = ""

  command <<<
  set -euo pipefail

  # Rename input files to published versions
  test -f sample_coverage.txt || mv ~{sample_coverage} sample_coverage.txt
  test -f amplicon_coverage.txt || mv ~{amplicon_coverage} amplicon_coverage.txt

  test -d quality_report || mkdir quality_report

  Rscript /bin/cutadapt_summaryplots.R \
    amplicon_coverage.txt \
    sample_coverage.txt \
    ~{amplicon_info} \
    quality_report

  >>>

  output {
    File sample_coverage_out = "sample_coverage.txt"
    File amplicon_coverage_out = "amplicon_coverage.txt"
  }

  runtime {
    docker: "~{docker_image}"
    cpu: 1
    memory: "8G"
  }

}

