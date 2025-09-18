version 1.0

import "modules/local/create_primer_files.wdl" as CreatePrimerFiles

# Can be used for testing subworkflows and modules
workflow CreatePrimerFilesTest {
    input {
        File amplicon_info
        String docker_name = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call CreatePrimerFiles.create_primer_files {
        input:
            amplicon_info = amplicon_info,
            docker_name = docker_name
    }

    output {
        File fwd_primers = create_primer_files.fwd_primers
        File rev_primers = create_primer_files.rev_primers

    }
}