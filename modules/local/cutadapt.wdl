version 1.0

task cutadapt {
  input {
    File fwd_primers
    File rev_primers
    File reads_1
    File reads_2
    Int cutadapt_minlen
    String sequencer
    Int allowed_errors
    #TODO: Should this be used in runtime?
    Int cores = 1
    String docker_image = "eppicenter/mad4hatter:dev"
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
      -c ~{cores} \
      -o demultiplexed_fastqs
  >>>

  output {
    File sample_summary = glob("*.SAMPLEsummary.txt")[0]
    File amplicon_summary = glob("*.AMPLICONsummary.txt")[0]
    Array[File] demultiplexed_fastqs = glob("demultiplexed_fastqs/*")
  }

  runtime {
    docker: docker_image
  }
}