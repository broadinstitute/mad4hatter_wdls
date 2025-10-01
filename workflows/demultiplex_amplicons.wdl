version 1.0

import "../modules/local/create_primer_files.wdl" as create_primer_files
import "../modules/local/cutadapt.wdl" as cutadapt

workflow demultiplex_amplicons {
  input {
    File amplicon_info_ch
    Array[File] left_fastqs
    Array[File] right_fastqs
    String sequencer
    Int cutadapt_minlen
    Int allowed_errors
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  Array[Pair[File, File]] read_pairs = zip(left_fastqs, right_fastqs)

  call create_primer_files.create_primer_files {
    input:
      amplicon_info_ch = amplicon_info_ch,
      docker_image = docker_image
  }

  scatter (read_pair in read_pairs) {
    call cutadapt.cutadapt {
      input:
        fwd_primers = create_primer_files.fwd_primers,
        rev_primers = create_primer_files.rev_primers,
        reads_1 = read_pair.left,
        reads_2 = read_pair.right,
        cutadapt_minlen = cutadapt_minlen,
        sequencer = sequencer,
        allowed_errors = allowed_errors,
        docker_image = docker_image
    }
  }

  output {
    Array[File] sample_summary_ch = cutadapt.sample_summary
    Array[File] amplicon_summary_ch = cutadapt.amplicon_summary
    Array[File] demux_fastqs_ch = cutadapt.demultiplexed_fastqs
  }
}