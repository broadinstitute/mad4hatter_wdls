version 1.0

import "workflows/demultiplex_amplicons.wdl" as demultiplex_amplicons

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File amplicon_info
        Array[File] left_fastqs
        Array[File] right_fastqs
        Int cutadapt_minlen = 100
        String? sequencer = ""
        Int allowed_errors = 0
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call demultiplex_amplicons.demultiplex_amplicons as demultiplex_amplicons {
        input:
            amplicon_info = amplicon_info,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            cutadapt_minlen = cutadapt_minlen,
            sequencer = sequencer,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    output {
        Array[File] sample_summary_ch = demultiplex_amplicons.sample_summary_ch
        Array[File] amplicon_summary_ch = demultiplex_amplicons.amplicon_summary_ch
        Array[File] demux_fastqs_ch = demultiplex_amplicons.demux_fastqs_ch
    }
}