version 1.0

import "demultiplex_amplicons.wdl" as demultiplex_amplicons
import "quality_control.wdl" as quality_control

# This workflow is meant to drive quality control of amplicon sequencing data
workflow qc_only {
    input {
        File amplicon_info_ch
        Array[File] left_fastqs
        Array[File] right_fastqs
        String sequencer
        Int cutadapt_minlen
        Int allowed_errors
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    call demultiplex_amplicons.demultiplex_amplicons {
        input:
            amplicon_info_ch = amplicon_info_ch,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            sequencer = sequencer,
            cutadapt_minlen = cutadapt_minlen,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    call quality_control.quality_control {
        input:
            amplicon_info_ch = amplicon_info_ch,
            sample_coverage_files = demultiplex_amplicons.sample_summary_ch,
            amplicon_coverage_files = demultiplex_amplicons.amplicon_summary_ch,
            docker_image = docker_image
    }

    output {
        File sample_coverage_out = quality_control.sample_coverage_out
        File amplicon_coverage_out = quality_control.amplicon_coverage_out
        File amplicon_stats = quality_control.amplicon_stats
        File length_vs_reads = quality_control.length_vs_reads
        File qc_plots_html = quality_control.qc_plots_html
        File qc_plots_rmd = quality_control.qc_plots_rmd
        File reads_histograms = quality_control.reads_histograms
        File swarm_plots = quality_control.swarm_plots
    }
}

