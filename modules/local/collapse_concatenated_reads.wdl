task collapse_concatenated_reads {
  input {
    File clusters
    String docker_name = "your_docker_image"
  }

  command <<<
    Rscript /bin/collapse_concatenated_reads.R \
      --clusters ~{clusters}
  >>>

  output {
    File clusters_concatenated_collapsed = "clusters.concatenated.collapsed.txt"
  }

  runtime {
    docker: docker_name
  }
}