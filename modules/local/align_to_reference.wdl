version 1.0

task align_to_reference {
    input {
        File clusters
        File refseq_fasta
        File amplicon_info_ch
        Int cpus = 1
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    command <<<
        Rscript /opt/mad4hatter/bin/align_to_reference.R \
            --clusters ~{clusters} \
            --refseq-fasta ~{refseq_fasta} \
            --amplicon-table ~{amplicon_info_ch} \
            --n-cores ~{cpus}
    >>>

    output {
        File alignments = "alignments.txt"
    }

    runtime {
        docker: docker_image
        cpu: cpus
    }
}