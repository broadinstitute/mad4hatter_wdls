version 1.0

task build_pseudocigar {
  input {
    File alignments
    Int ncores = 1
    String docker_image = "eppicenter/mad4hatter:develop"
  }

  command <<<
    Rscript /opt/mad4hatter/bin/build_pseudocigar.R \
      --alignments ~{alignments} \
      --ncores ~{ncores}
  >>>

  output {
    File pseudocigar = "alignments.pseudocigar.txt"
  }

  runtime {
    docker: docker_image
  }
}