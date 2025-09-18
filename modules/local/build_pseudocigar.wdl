version 1.0

task build_pseudocigar {
  input {
    File alignments
    String docker_name = "eppicenter/mad4hatter:dev"
  }

  command <<<
    Rscript /opt/mad4hatter/bin/build_pseudocigar.R \
      --alignments ~{alignments}
  >>>

  output {
    File pseudocigar = "alignments.pseudocigar.txt"
  }

  runtime {
    docker: docker_name
  }
}