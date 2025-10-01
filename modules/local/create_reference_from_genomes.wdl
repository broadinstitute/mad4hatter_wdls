version 1.0

task create_reference_from_genomes {
  input {
    File genome
    File amplicon_info_ch
    String refseq_fasta
    Int n_cores = 1
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  # TODO should "PkPfPmPoPv.fasta" be added to the docker image and the path updated accordingly? Or is this always
  # TODO something provided by the user
  command <<<
    Rscript /opt/mad4hatter/bin/create_reference_from_genomes.R \
      --ampliconFILE ~{amplicon_info_ch} \
      --genome ~{genome} \
      --output ~{refseq_fasta} \
      --ncores ~{n_cores}
  >>>

  output {
    File reference_fasta = "~{refseq_fasta}"
  }

  runtime {
    docker: docker_image
    cpu: n_cores
  }
}