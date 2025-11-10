version 1.0

task mask_reference_tandem_repeats {
    input {
        File refseq_fasta
        Int min_score
        Int max_period
        Int mem_gb = 2
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    command <<<
        set -euo pipefail

        ls -l ~{refseq_fasta}
        md5sum ~{refseq_fasta}

        # Name the input file to a standard name so outputs are predictable
        mv ~{refseq_fasta} reference.fasta
        trf ~{refseq_fasta} 2 7 7 80 10 ~{min_score} ~{max_period} -h -m
    >>>

    output {
        File masked_fasta = "reference.fasta.2.7.7.80.10.~{min_score}.~{max_period}.mask"
    }

    runtime {
        docker: docker_image
        memory: "~{mem_gb} GB"
    }
}