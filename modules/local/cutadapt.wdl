version 1.0

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
    bash /opt/mad4hatter/bin/cutadapt_process.sh \
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
    File sample_summary_ch = glob("*.SAMPLEsummary.txt")[0]
    File amplicon_summary_ch = glob("*.AMPLICONsummary.txt")[0]
    Directory demux_fastqs_ch = "demultiplexed_fastqs"
  }

  runtime {
    docker: docker_name
  }
}