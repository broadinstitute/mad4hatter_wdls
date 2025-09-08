task cutadapt {
  input {
    File fwd_primers
    File rev_primers
    File reads_1
    File reads_2
    String pair_id
    Int cutadapt_minlen
    String sequencer
    Float allowed_errors
    #TODO: Should this be used in runtime?
    Int cpus = 1
    String docker_name = "your_docker_image"
  }

  command <<<
    bash /bin/cutadapt_process.sh \
      -1 ~{reads_1} \
      -2 ~{reads_2} \
      -r ~{rev_primers} \
      -f ~{fwd_primers} \
      -m ~{cutadapt_minlen} \
      -s ~{sequencer} \
      -e ~{allowed_errors} \
      -c ~{cpus} \
      -o demultiplexed_fastqs
  >>>

  output {
    File sample_summary = glob("*.SAMPLEsummary.txt")[0]
    File amplicon_summary = glob("*.AMPLICONsummary.txt")[0]
    # nextflow returned a directory, so will need change workflows that call this
    Array[File] demultiplexed_fastqs = glob("demultiplexed_fastqs/*")
  }

  runtime {
    docker: docker_name
  }
}