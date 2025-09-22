version 1.0

import "modules/local/cutadapt.wdl" as CutAdapt

# Can be used for testing subworkflows and modules
workflow CutAdaptTest {
    input {
        File fwd_primers
        File rev_primers
        File reads_1
        File reads_2
        Int cutadapt_minlen
        String sequencer
        Int allowed_errors
    }

    # Testing task
    call CutAdapt.cutadapt {
        input:
            fwd_primers = fwd_primers,
            rev_primers = rev_primers,
            reads_1 = reads_1,
            reads_2 = reads_2,
            cutadapt_minlen = cutadapt_minlen,
            sequencer = sequencer,
            allowed_errors = allowed_errors
    }

    output {
        File sample_summary = cutadapt.sample_summary
        File amplicon_summary = cutadapt.amplicon_summary
        Array[File] demultiplexed_fastqs = cutadapt.demultiplexed_fastqs
    }
}