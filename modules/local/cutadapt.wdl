version 1.0

task cutadapt {
    input {
        File fwd_primers
        File rev_primers
        File reads_1
        File reads_2
        Int cutadapt_minlen
        String sequencer
        Int allowed_errors
        Int cpus = 1
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    command <<<
        OUTPUT_DIR="demultiplexed_fastqs"

        bash /opt/mad4hatter/bin/cutadapt_process.sh \
            -1 ~{reads_1} \
            -2 ~{reads_2} \
            -r ~{rev_primers} \
            -f ~{fwd_primers} \
            -m ~{cutadapt_minlen} \
            -s ~{sequencer} \
            -e ~{allowed_errors} \
            -c ~{cpus} \
            -o $OUTPUT_DIR

        echo "Creating tarball of fastq files"
        tar -czf fastqs.tar.gz -C "$OUTPUT_DIR" $(basename -a $OUTPUT_DIR/*.fastq.gz)
    >>>

    output {
        File sample_summary = glob("*.SAMPLEsummary.txt")[0]
        File amplicon_summary = glob("*.AMPLICONsummary.txt")[0]
        File demultiplexed_fastqs = "fastqs.tar.gz"
    }

    runtime {
        docker: docker_image
        cpu: cpus
    }
}