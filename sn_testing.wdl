version 1.0

import "modules/local/mask_reference_tandem_repeats.wdl" as MaskReferenceTandemRepeats

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File refseq_fasta
        Int min_score
        Int max_period
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call MaskReferenceTandemRepeats.mask_reference_tandem_repeats as z {
        input:
            refseq_fasta = refseq_fasta,
            min_score = min_score,
            max_period = max_period,
            docker_image = docker_image
    }

    output {
        File masked_fasta = z.masked_fasta
    }
}