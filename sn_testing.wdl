version 1.0

import "modules/local/filter_asvs.wdl" as FilterAsvs

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File alignments
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call FilterAsvs.filter_asvs as filter_asvs {
        input:
            docker_image = docker_image,
            alignments = alignments
    }

    output {
        File filtered_alignments_ch = filter_asvs.filtered_alignments_ch
    }
}