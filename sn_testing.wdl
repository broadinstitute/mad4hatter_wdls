version 1.0

import "modules/local/mask_reference_tandem_repeats.wdl" as mask_reference_tandem_repeats

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File refseq_fasta
        Int min_score
        Int max_period
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call mask_reference_tandem_repeats.mask_reference_tandem_repeats {
        input:
            refseq_fasta = refseq_fasta,
            min_score = min_score,
            max_period = max_period,
            docker_image = docker_image
    }

    output {
        File masked_fasta = mask_reference_tandem_repeats.masked_fasta
    }
}