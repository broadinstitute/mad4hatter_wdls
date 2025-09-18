version 1.0

import "modules/local/post_process_coverage.wdl" as post_process_coverage

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File alleledata
        File clusters
        File sample_coverage
        File amplicon_coverage
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call post_process_coverage.post_process_coverage as post_process_coverage {
        input:
            alleledata = alleledata,
            clusters = clusters,
            sample_coverage = sample_coverage,
            amplicon_coverage = amplicon_coverage,
            docker_image = docker_image
    }

    output {
        File postprocess_sample_coverage = post_process_coverage.postprocess_sample_coverage
        File postprocess_amplicon_coverage = post_process_coverage.postprocess_amplicon_coverage
    }
}