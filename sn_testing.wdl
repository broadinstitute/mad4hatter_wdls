version 1.0

import "modules/local/mask_sequences.wdl" as mask_sequences

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        Array[File] masks
        String docker_image = "eppicenter/mad4hatter:dev"
        File alignments
        Int cpus = 1
    }

    # Testing task
    call mask_sequences.mask_sequences as mask_sequences {
        input:
            docker_image = docker_image,
            masks = masks,
            alignments = alignments,
            cpus = cpus
    }

    output {
        File masked_alignments = mask_sequences.masked_alignments
    }
}