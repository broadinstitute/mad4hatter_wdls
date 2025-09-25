version 1.0

import "subworkflows/local/prepare_reference_sequences.wdl" as prepare_reference_sequences

# Can be used for testing subworkflows and modules
workflow PrepareReferenceSequencesTesting {
    input {
        File? amplicon_info
        File? genome
        Array[File]? reference_input_paths
    }

    call prepare_reference_sequences.prepare_reference_sequences {
        input:
            amplicon_info = amplicon_info,
            genome = genome,
            reference_input_paths = reference_input_paths
    }

    output {
        File reference_fasta = prepare_reference_sequences.reference_fasta
    }
}