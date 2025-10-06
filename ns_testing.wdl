version 1.0

import "subworkflows/local/prepare_reference_sequences.wdl" as PrepareReferenceSequences

# Can be used for testing subworkflows and modules
workflow PrepareReferenceSequencesTest {
    input {
        File? amplicon_info_ch
        File? genome
        Array[File]? reference_input_paths
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call PrepareReferenceSequences.prepare_reference_sequences {
        input:
            amplicon_info_ch = amplicon_info_ch,
            genome = genome,
            reference_input_paths = reference_input_paths,
            docker_image = docker_image
    }

    output {
        File reference_fasta = prepare_reference_sequences.reference_fasta
    }
}