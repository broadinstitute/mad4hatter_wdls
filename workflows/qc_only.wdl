version 1.0

import "demultiplex_amplicons.wdl" as demultiplex_amplicons
import "quality_control.wdl" as quality_control

# This workflow is meant to drive quality control of amplicon sequencing data
workflow qc_only {
    input {
        File amplicon_info
        Array[File] left_fastqs
        Array[File] right_fastqs
        String sequencer
        Int? cutadapt_minlen
        Int? allowed_errors
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    call demultiplex_amplicons.demultiplex_amplicons {
        input:
            amplicon_info = amplicon_info,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            sequencer = sequencer,
            cutadapt_minlen = cutadapt_minlen,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    call quality_control.quality_control {
        input:
            amplicon_info = amplicon_info,
            sample_coverage_files = demultiplex_amplicons.sample_summary_ch,
            amplicon_coverage_files = demultiplex_amplicons.amplicon_summary_ch,
            docker_image = docker_image
    }

}

