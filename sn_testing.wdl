version 1.0

import "workflows/denoise_amplicons_1.wdl" as denoise_amplicons_1

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File amplicon_info
        Array[File] demultiplexed_dir_tars
        String dada2_pool
        Int band_size
        Float omega_a
        Int maxEE
        Boolean just_concatenate
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call denoise_amplicons_1.denoise_amplicons_1 {
        input:
            amplicon_info = amplicon_info,
            demultiplexed_dir_tars = demultiplexed_dir_tars,
            dada2_pool = dada2_pool,
            band_size = band_size,
            omega_a = omega_a,
            maxEE = maxEE,
            just_concatenate = just_concatenate,
            docker_image = docker_image
    }

    output {
        File dada2_clusters = denoise_amplicons_1.dada2_clusters
    }
}