version 1.0

import "workflows/demultiplex_amplicons.wdl" as demultiplex_amplicons

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File amplicon_info
        Array[Pair[File, File]] read_pairs
        Int cutadapt_minlen = 100
        String? sequencer = ""
        Int allowed_errors = 0
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call demultiplex_amplicons.demultiplex_amplicons as demultiplex_amplicons {
        input:
            amplicon_info = amplicon_info,
            read_pairs = read_pairs,
            cutadapt_minlen = cutadapt_minlen,
            sequencer = sequencer,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    output {
        Array[File] sample_summary_ch = demultiplex_amplicons.sample_summary
        Array[File] amplicon_summary_ch = demultiplex_amplicons.amplicon_summary
        Array[File] demux_fastqs_ch = demultiplex_amplicons.demultiplexed_fastqs
    }
}