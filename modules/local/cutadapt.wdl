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
    Int cpus = 1 # Should this be used in runtime?
    String docker_name = "your_docker_image"
  }

  command <<<
    bash cutadapt_process.sh \
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
    File sample_summary = "*.SAMPLEsummary.txt"
    File amplicon_summary = "*.AMPLICONsummary.txt"
    Directory demultiplexed_fastqs = "demultiplexed_fastqs"
  }

  runtime {
    docker: docker_name
  }
}