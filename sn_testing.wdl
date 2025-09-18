version 1.0

import "modules/local/preprocess_coverage.wdl" as preprocess_coverage

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        Array[File] sample_coverages
        Array[File] amplicon_coverages
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call preprocess_coverage.preprocess_coverage as preprocess_coverage {
        input:
            sample_coverages = sample_coverages,
            amplicon_coverages = amplicon_coverages,
            docker_image = docker_image
    }

    output {
        File sample_coverage = preprocess_coverage.sample_coverage
        File amplicon_coverage = preprocess_coverage.amplicon_coverage
    }
}