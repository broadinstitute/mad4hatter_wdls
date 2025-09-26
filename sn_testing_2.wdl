version 1.0

import "workflows/denoise_amplicons_2.wdl" as denoise_amplicons_2

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File amplicon_info
        File denoise_ch
        Boolean just_concatenate
        File? refseq_fasta
        File? masked_fasta
        Boolean mask_tandem_repeats
        Boolean mask_homopolymers
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call denoise_amplicons_2.denoise_amplicons_2 {
        input:
            amplicon_info = amplicon_info,
            denoise_ch = denoise_ch,
            refseq_fasta = refseq_fasta,
            masked_fasta = masked_fasta,
            mask_tandem_repeats = mask_tandem_repeats,
            mask_homopolymers = mask_homopolymers,
            just_concatenate = just_concatenate,
            docker_image = docker_image
    }

    output {
        File results_ch = denoise_amplicons_2.results_ch
        File reference_ch = denoise_amplicons_2.reference_ch
        File aligned_asv_table = denoise_amplicons_2.aligned_asv_table
    }
}