task build_pseudocigar {
  input {
    File alignments
    String docker_name = "your_docker_image"
  }

  command <<<
    Rscript ./bin/build_pseudocigar.R \
      --alignments ~{alignments}
  >>>

  output {
    File pseudocigar = "alignments.pseudocigar.txt"
  }

  runtime {
    docker: docker_name
  }
}