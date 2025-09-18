version 1.0

import "modules/local/build_pseudocigar.wdl" as BuildPseudocigar

# Can be used for testing subworkflows and modules
workflow BuildPseudocigarTest {
    input {
        File alignments
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call BuildPseudocigar.build_pseudocigar {
        input:
            alignments = alignments,
            docker_name = docker_image
    }

    output {
        File pseudocigar = build_pseudocigar.pseudocigar
    }
}