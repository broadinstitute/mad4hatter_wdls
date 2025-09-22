version 1.0

import "modules/local/build_resources.wdl" as BuildResources

# Can be used for testing subworkflows and modules
workflow BuildResourcesTest {
    input {
        Array[String] pools
        Array[File] amplicon_info_paths
    }

    # Testing task
    call BuildResources.build_amplicon_info {
        input:
            pools = pools,
            amplicon_info_paths = amplicon_info_paths
    }

    output {
        File amplicon_info = build_amplicon_info.amplicon_info
    }
}