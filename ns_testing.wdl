version 1.0

import "modules/local/align_to_reference.wdl" as AlignToRef

# Can be used for testing subworkflows and modules
workflow AlignToReferenceTest {
    input {
        File clusters
        File refseq_fasta
        File amplicon_info
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call AlignToRef.align_to_reference {
        input:
            docker_name = docker_image,
            clusters = clusters,
            refseq_fasta = refseq_fasta,
            amplicon_info = amplicon_info
    }

    output {
        File alignments = align_to_reference.alignments
    }
}