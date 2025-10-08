version 1.0

# Prepare the primer files from the given amplicon_info file
task filter_asvs {
    input {
        File alignments
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Pulled default value from https://github.com/EPPIcenter/mad4hatter/blob/0fdf688d8bef6b1407de66ed2644a2d26635015d/nextflow.config#L32
    Int alignment_threshold = 60


    command <<<
        set -euo pipefail

        bash /opt/mad4hatter/bin/filter_asv_process.sh \
            -i ~{alignments} \
            -o filtered.alignments.txt \
            -t ~{alignment_threshold}
    >>>

    output {
        File filtered_alignments_ch = "filtered.alignments.txt"
    }

    runtime {
        docker: docker_image
        #TODO: Should we hardcode this?
        memory: "8G"
    }
}