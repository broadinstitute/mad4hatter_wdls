version 1.0

import "../modules/local/create_primer_files.wdl" as create_primer_files
import "../modules/local/cutadapt.wdl" as cutadapt
# This was imported but not used in the original Nexflow workflow
#import "../modules/local/quality_report.wdl" as quality_report

workflow demultiplex_amplicons {
  input {
    File amplicon_info
    Array[Pair[String, Pair[File, File]]] read_pairs
    Int cutadapt_minlen
    String sequencer
    Float allowed_errors
    String docker_name = "your_docker_image"
  }

  call create_primer_files.create_primer_files {
    input:
      amplicon_info = amplicon_info,
      docker_name = docker_name
  }

  scatter (read_pair in read_pairs) {
    call cutadapt.cutadapt {
      input:
        fwd_primers = create_primer_files.fwd_primers,
        rev_primers = create_primer_files.rev_primers,
        reads_1 = read_pair.right.left,
        reads_2 = read_pair.right.right,
        pair_id = read_pair.left,
        cutadapt_minlen = cutadapt_minlen,
        sequencer = sequencer,
        allowed_errors = allowed_errors,
        docker_name = docker_name
    }
  }

  output {
    Array[File] sample_summary_ch = cutadapt.sample_summary_ch
    Array[File] amplicon_summary_ch = cutadapt.amplicon_summary_ch
    Array[Directory] demux_fastqs_ch = cutadapt.demux_fastqs_ch
  }
}