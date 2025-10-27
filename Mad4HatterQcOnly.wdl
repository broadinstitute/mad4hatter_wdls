version 1.0

import "workflows/process_inputs.wdl" as ProcessInputs
import "workflows/qc_only.wdl" as QcOnly

workflow Mad4HatterQcOnly {
    input {
        Array[String] pools
        Array[File] amplicon_info_files
        Array[File] left_fastqs
        Array[File] right_fastqs
        String sequencer
        Int cutadapt_minlen = 100
        Int allowed_errors = 0
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    call ProcessInputs.generate_amplicon_info {
        input:
            pools = pools,
            docker_image = docker_image,
            amplicon_info_files = amplicon_info_files
    }

    call QcOnly.qc_only {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            sequencer = sequencer,
            cutadapt_minlen = cutadapt_minlen,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    output {
        File amplicon_info = generate_amplicon_info.amplicon_info_ch
        File amplicon_coverage = qc_only.sample_coverage_out
        File sample_coverage = qc_only.amplicon_coverage_out
    }
}