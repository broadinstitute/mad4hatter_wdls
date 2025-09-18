version 1.0

import "modules/local/mask_reference_homopolymers.wdl" as MaskReferenceHomopolymers

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File refseq_fasta
        String docker_image = "eppicenter/mad4hatter:dev"
        Int homopolymer_threshold
    }

    # Testing task
    call MaskReferenceHomopolymers.mask_reference_homopolymers as mask_reference_homopolymers {
        input:
            docker_image = docker_image,
            refseq_fasta = refseq_fasta,
            homopolymer_threshold = homopolymer_threshold
    }

    output {
        File masked_fasta = mask_reference_homopolymers.masked_fasta
    }
}