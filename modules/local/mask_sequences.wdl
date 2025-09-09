version 1.0

task mask_sequences {
  input {
      Array[File] masks
      File alignments
      Int cpus = 1
  }

  # TODO: Fill in docker image here when available
  String docker_image = ""

  command <<<
  Rscript /bin/mask_sequences.R \
      --masks ~{sep="," masks} \
      --alignments ~{alignments} \
      --n-cores ~{cpus}
  >>>

  output {
      File masked_alignments = "masked.alignments.txt"
  }

  runtime {
      docker: "~{docker_image}"
      cpu: 1
      memory: "8G"
  }
}



