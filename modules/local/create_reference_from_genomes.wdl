task create_reference_from_genomes {
  input {
    File genome
    File amplicon_info
    String refseq_fasta
    Int n_cores # Should this be used in runtime?
    String docker_name = "your_docker_image"
  }

  command <<<
    Rscript ./bin/create_reference_from_genomes.R \
      --ampliconFILE ~{amplicon_info} \
      --genome ~{genome} \
      --output ~{refseq_fasta} \
      --ncores ~{n_cores}
  >>>

  output {
    File reference_fasta = "~{refseq_fasta}"
  }

  runtime {
    docker: docker_name
  }
}