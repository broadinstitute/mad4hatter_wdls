version 1.0

task align_to_reference {
  input {
    File clusters
    File refseq_fasta
    File amplicon_info
    #TODO: Should this be used in runtime?
    Int n_cores = 1
    String docker_name = "your_docker_image"
  }

  command <<<
    Rscript /bin/align_to_reference.R \
      --clusters ~{clusters} \
      --refseq-fasta ~{refseq_fasta} \
      --amplicon-table ~{amplicon_info} \
      --n-cores ~{n_cores}
  >>>

  output {
    File alignments = "alignments.txt"
  }

  runtime {
    docker: docker_name
  }
}