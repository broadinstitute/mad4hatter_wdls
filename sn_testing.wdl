version 1.2

import "modules/local/dada2_analysis.wdl" as dada2_analysis

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        Directory demultiplexed_dirs
        File amplicon_info
        String dada2_pool
        Int band_size
        Float omega_a
        Int maxEE
        Boolean just_concatenate
        Int cpus = 1
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call dada2_analysis.dada2_analysis as dada2_analysis {
        input:
            demultiplexed_dirs = demultiplexed_dirs,
            amplicon_info = amplicon_info,
            dada2_pool = dada2_pool,
            omega_a = omega_a,
            band_size = band_size,
            maxEE = maxEE,
            just_concatenate = just_concatenate,
            cpus = cpus,
            docker_image = docker_image
    }

    output {
        File dada2_clusters = dada2_analysis.dada2_clusters
    }
}