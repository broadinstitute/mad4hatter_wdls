version 1.0

import "modules/local/build_alleletable.wdl" as BuildAlleleTable

# Can be used for testing subworkflows and modules
workflow BuildAlleleTableTest {
    input {
        File amplicon_info
        File denoised_asvs
        File processed_asvs
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call BuildAlleleTable.build_alleletable {
        input:
            amplicon_info = amplicon_info,
            denoised_asvs = denoised_asvs,
            processed_asvs = processed_asvs,
            docker_image = docker_image
    }

    output {
        File alleledata = build_alleletable.alleledata
    }
}