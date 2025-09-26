version 1.0

import "workflows/postproc_only.wdl" as postproc_only

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File amplicon_info
        File clusters
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call postproc_only.postproc_only {
        input:
            amplicon_info = amplicon_info,
            clusters = clusters,
            docker_image = docker_image
    }

    output {
        File reference_ch = postproc_only.reference_ch
        File aligned_asv_table = postproc_only.aligned_asv_table
        File alleledata = postproc_only.alleledata
    }
}