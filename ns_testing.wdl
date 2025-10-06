version 1.0

import "workflows/resistance_marker_module.wdl" as ResistanceMarker

# Can be used for testing subworkflows and modules
workflow ResistanceMarkerTest {
    input {
        File amplicon_info_ch
        File allele_data
        File alignment_data
        File reference
        File? resmarkers_amplicon
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call ResistanceMarker.resistance_marker_module {
        input:
            amplicon_info_ch = amplicon_info_ch,
            allele_data = allele_data,
            alignment_data = alignment_data,
            reference = reference,
            resmarkers_amplicon = resmarkers_amplicon,
            docker_image = docker_image
    }

    output {
        File resmarkers_output = resistance_marker_module.resmarkers_output
        File resmarkers_by_locus = resistance_marker_module.resmarkers_by_locus
        File microhaps = resistance_marker_module.microhaps
        File new_mutations = resistance_marker_module.new_mutations
    }
}