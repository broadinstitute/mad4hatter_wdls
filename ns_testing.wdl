version 1.0

import "workflows/qc_only.wdl" as QcOnly

# Can be used for testing subworkflows and modules
workflow QcOnlyTest {
    input {
        File amplicon_info_ch
        Array[File] left_fastqs
        Array[File] right_fastqs
        String sequencer
        Int? cutadapt_minlen
        Int? allowed_errors
    }

    # Testing task
    call QcOnly.qc_only {
        input:
            amplicon_info_ch = amplicon_info_ch,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            sequencer = sequencer,
            cutadapt_minlen = cutadapt_minlen,
            allowed_errors = allowed_errors
    }

    output {
        File sample_coverage_out = qc_only.sample_coverage_out
        File amplicon_coverage_out = qc_only.amplicon_coverage_out
        Array[File] quality_reports = qc_only.quality_reports
    }
}