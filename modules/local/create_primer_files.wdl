task create_primer_files {
  input {
    File amplicon_info
    String docker_name = "your_docker_image"
  }

  command <<<
    bash create_primer_files.sh -a ~{amplicon_info} \
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