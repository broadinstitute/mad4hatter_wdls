version 1.0

import "modules/local/build_resources.wdl" as BuildResources

# Can be used for testing subworkflows and modules
workflow BuildResourcesTest {
    input {
        File amplicon_info
        File principal_resmarkers
        String docker_name = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call BuildResources.build_resmarker_info {
        input:
            amplicon_info = amplicon_info,
            principal_resmarkers = principal_resmarkers,
            docker_name = docker_name
    }

    output {
        File resmarker_info = build_resmarker_info.resmarker_info
    }
}