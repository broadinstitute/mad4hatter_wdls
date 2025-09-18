version 1.0

import "modules/local/collapse_concatenated_reads.wdl" as CollapseConcatenatedReads

# Can be used for testing subworkflows and modules
workflow CollapseConcatenatedReadsTest {
    input {
        File clusters
        String docker_name = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call CollapseConcatenatedReads.collapse_concatenated_reads {
        input:
            clusters = clusters,
            docker_name = docker_name
    }

    output {
        File clusters_concatenated_collapsed = collapse_concatenated_reads.clusters_concatenated_collapsed

    }
}