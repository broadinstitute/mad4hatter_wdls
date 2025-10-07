version 1.0

import "workflows/postproc_only.wdl" as PostProcOnly

# Can be used for testing subworkflows and modules
workflow PostProcOnlyTest {
    input {
        File amplicon_info_ch
        File clusters
        Boolean just_concatenate
        Boolean mask_tandem_repeats
        Boolean mask_homopolymers
        File? genome
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call PostProcOnly.postproc_only {
        input:
            amplicon_info_ch = amplicon_info_ch,
            clusters = clusters,
            just_concatenate = just_concatenate,
            mask_tandem_repeats = mask_tandem_repeats,
            mask_homopolymers = mask_homopolymers,
            genome = genome,
            docker_image = docker_image
    }

    output {
        File reference_ch = postproc_only.reference_ch
        File aligned_asv_table = postproc_only.aligned_asv_table
        File alleledata = postproc_only.alleledata
    }
}