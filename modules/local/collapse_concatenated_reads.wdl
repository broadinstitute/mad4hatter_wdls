version 1.0

task collapse_concatenated_reads {
  input {
    File clusters
    String docker_image = "eppicenter/mad4hatter:develop"
  }

  command <<<
    Rscript /opt/mad4hatter/bin/collapse_concatenated_reads.R \
      --clusters ~{clusters}
  >>>

  output {
    File clusters_concatenated_collapsed = "clusters.concatenated.collapsed.txt"
  }

  runtime {
    docker: docker_image
  }
}