version 1.0

task mask_reference_tandem_repeats {
  input {
      File refseq_fasta
      Int min_score
      Int max_period
  }

  # TODO: Fill in docker image here when available
  String docker_image = ""

  command <<<
  set -euo pipefail

  trf ~{refseq_fasta} 2 7 7 80 10 ~{min_score} ~{max_period} -h -m
  >>>

  output {
      File masked_fasta = "*.mask"
  }

  runtime {
      docker: "~{docker_image}"
      cpu: 1
      memory: "8G"
  }
}