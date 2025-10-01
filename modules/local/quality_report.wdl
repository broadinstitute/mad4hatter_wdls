version 1.0

task quality_report {
  input {
    File sample_coverage
    File amplicon_coverage
    File amplicon_info_ch
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
  set -euo pipefail

  # Rename input files to published versions
  test -f sample_coverage.txt || mv ~{sample_coverage} sample_coverage.txt
  test -f amplicon_coverage.txt || mv ~{amplicon_coverage} amplicon_coverage.txt

  test -d quality_report || mkdir quality_report

  Rscript /opt/mad4hatter/bin/cutadapt_summaryplots.R \
    amplicon_coverage.txt \
    sample_coverage.txt \
    ~{amplicon_info_ch} \
    quality_report

  >>>

  output {
    File sample_coverage_out = "sample_coverage.txt"
    File amplicon_coverage_out = "amplicon_coverage.txt"
    Array[File] quality_reports = glob("quality_report/*")
  }

  runtime {
    docker: docker_image
    #TODO: Should we hardcode this?
    memory: "8G"
  }
}

