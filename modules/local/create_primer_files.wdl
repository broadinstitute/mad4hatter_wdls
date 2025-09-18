version 1.0

task create_primer_files {
  input {
    File amplicon_info
    String docker_name = "eppicenter/mad4hatter:dev"
  }

  command <<<
    bash /bin/create_primer_files.sh -a ~{amplicon_info} \
      -f fwd_primers.fasta \
      -r rev_primers.fasta
  >>>

  output {
    File fwd_primers = "fwd_primers.fasta"
    File rev_primers = "rev_primers.fasta"
  }

  runtime {
    docker: docker_name
  }
}