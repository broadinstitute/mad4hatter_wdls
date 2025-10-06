version 1.0

import "modules/create_reference_from_genomes.wdl" as CreateReference

# Can be used for testing subworkflows and modules
workflow CreateReferenceTest {
    input {
        File genome
        File amplicon_info_ch
        String refseq_fasta
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call CreateReference.create_reference_from_genomes {
        input:
            genome = genome,
            amplicon_info_ch = amplicon_info_ch,
            refseq_fasta = refseq_fasta,
            docker_image = docker_image
    }

    output {
        File reference_fasta = create_reference_from_genomes.reference_fasta
    }
}