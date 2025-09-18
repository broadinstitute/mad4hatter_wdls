version 1.0

import "modules/local/build_resources.wdl" as BuildResources

# Can be used for testing subworkflows and modules
workflow BuildResourcesTest {
    input {
        Array[File] reference_input_paths
    }

    # Testing task
    call BuildResources.build_targeted_reference {
        input:
            reference_input_paths = reference_input_paths
    }

    output {
        File reference_fasta = build_targeted_reference.reference_fasta
    }
}