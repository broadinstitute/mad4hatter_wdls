version 1.0

import "modules/local/dada2_analysis.wdl" as dada2_analysis

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        Array[File] demultiplexed_dir_tars
        File amplicon_info_ch
        String dada2_pool
        Int band_size
        Float omega_a
        Int max_ee
        Boolean just_concatenate
        Int cpus = 2
        Int dada2_memory_multiplier = 1
        Int dada2_space_multiplier = 1
        String storage_type
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call dada2_analysis.dada2_analysis {
        input:
            demultiplexed_dir_tars = demultiplexed_dir_tars,
            amplicon_info_ch = amplicon_info_ch,
            dada2_pool = dada2_pool,
            band_size = band_size,
            omega_a = omega_a,
            max_ee = max_ee,
            just_concatenate = just_concatenate,
            cpus = cpus,
            memory_multiplier = dada2_memory_multiplier,
            space_multiplier = dada2_space_multiplier,
            docker_image = docker_image,
            storage_type = storage_type
    }

    output {
        File dada2_clusters = dada2_analysis.dada2_clusters
    }
}