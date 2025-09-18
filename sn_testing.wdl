version 1.0

import "modules/local/mask_reference_tandem_repeats.wdl" as MaskReferenceTandemRepeats

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File refseq_fasta
        String docker_image = "eppicenter/mad4hatter:dev"
        Int min_score
        Int max_period
    }

    # Testing task
    call MaskReferenceTandemRepeats.mask_reference_tandem_repeats as mask_reference_tandem_repeats {
        input:
            docker_image = docker_image,
            refseq_fasta = refseq_fasta,
            min_score = min_score,
            max_period = max_period
    }

    output {
        File masked_fasta = mask_reference_tandem_repeats.masked_fasta
    }
}