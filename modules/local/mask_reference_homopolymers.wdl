version 1.0

task mask_reference_homopolymers {
  input {
      File refseq_fasta
      Int homopolymer_threshold
  }

  # TODO: Fill in docker image here when available
  String docker_image = ""

  command <<<
  set -euo pipefail

  Rscript /bin/mask_homopolymers.R \
      --refseq-fasta ~{refseq_fasta} \
      --homopolymer_threshold ~{homopolymer_threshold}
      --fout "refseq.homopolymer.fasta.mask"
  >>>

  output {
      File masked_fasta = "refseq.homopolymer.fasta.mask"
  }

  runtime {
      docker: "~{docker_image}"
      cpu: 1
      memory: "8G"
  }
}