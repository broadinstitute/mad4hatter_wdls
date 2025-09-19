version 1.0

import "modules/local/align_to_reference.wdl" as AlignToReference

# Can be used for testing subworkflows and modules
workflow AlignToReferenceTest {
    input {
        File clusters
        File refseq_fasta
        File amplicon_info
    }

    # Testing task
    call AlignToReference.align_to_reference {
        input:
            clusters = clusters,
            refseq_fasta = refseq_fasta,
            amplicon_info = amplicon_info
    }

    output {
        File alignments = align_to_reference.alignments
    }
}