version 1.0

task create_primer_files {
  input {
    File amplicon_info_ch
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
    bash /opt/mad4hatter/bin/create_primer_files.sh -a ~{amplicon_info_ch} \
      -f fwd_primers.fasta \
      -r rev_primers.fasta
  >>>

  output {
    File fwd_primers = "fwd_primers.fasta"
    File rev_primers = "rev_primers.fasta"
  }

  runtime {
    docker: docker_image
  }
}