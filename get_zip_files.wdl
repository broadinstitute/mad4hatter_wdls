version 1.0

import "workflows/demultiplex_amplicons.wdl" as DemultiplexAmpliconsWf
import "workflows/process_inputs.wdl" as ProcessInputsWf

## MAD4HatTeR Main Workflow
##
## This is the main workflow for MAD4HatTeR (Malaria Amplicon Deep-sequencing for Haplotype and Target Resistance)
## pipeline. It processes amplicon sequencing data through demultiplexing, denoising, quality control,
## and resistance marker analysis.


workflow MAD4HatTeR {
    input {
        Array[String] pools
        String sequencer # The sequencer used to produce your data
        Array[File] left_fastqs # List of left fastqs. Must be in correct order.
        Array[File] right_fastqs # List of right fastqs. Must be in correct order.
        Array[File] amplicon_info_files
        Int cutadapt_minlen = 100
        Int allowed_errors = 0
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Generate final amplicon info
    call ProcessInputsWf.generate_amplicon_info {
        input:
            pools = pools,
            docker_image = docker_image,
            amplicon_info_files = amplicon_info_files
    }

    # Step 1: Demultiplex amplicons by target region
    # This separates reads by amplicon target and performs initial quality filtering
    call DemultiplexAmpliconsWf.demultiplex_amplicons {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            sequencer = sequencer,
            cutadapt_minlen = cutadapt_minlen,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    output {
        Array[File] zip_files = demultiplex_amplicons.demux_fastqs_ch
    }
}