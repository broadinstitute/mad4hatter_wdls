version 1.0

import "workflows/resistance_marker_module.wdl" as ResistanceMarkerModule

# Can be used for testing subworkflows and modules
workflow ResistanceMarkerModuleTest {
    input {
        File amplicon_info
        File allele_data
        File alignment_data
        File reference
        File? resmarkers_amplicon
    }

    # Testing task
    call ResistanceMarkerModule.resistance_marker_module {
        input:
            amplicon_info = amplicon_info,
            allele_data = allele_data,
            alignment_data = alignment_data,
            reference = reference,
            resmarkers_amplicon = resmarkers_amplicon
    }

    output {
        File resmarkers_output = resistance_marker_module.resmarkers_output
        File resmarkers_by_locus = resistance_marker_module.resmarkers_by_locus
        File microhaps = resistance_marker_module.microhaps
        File new_mutations = resistance_marker_module.new_mutations
    }
}