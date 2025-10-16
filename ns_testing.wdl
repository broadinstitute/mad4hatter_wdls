version 1.0

import "modules/local/build_resmarker_info_and_resistance_table.wdl" as build_resmarker_info_and_resistance_table

# Can be used for testing subworkflows and modules
workflow BuildResmarkerInfoAndResistanceTableTesting {
    input {
        File alleledata
        File alignment_data
        File refseq
        File amplicon_info_ch
        File? principal_resmarkers
        File? resmarkers_amplicon
    }

    # Testing task
    call build_resmarker_info_and_resistance_table.build_resmarker_info_and_resistance_table {
        input:
            alleledata = alleledata,
            alignment_data = alignment_data,
            refseq = refseq,
            amplicon_info_ch = amplicon_info_ch,
            principal_resmarkers = principal_resmarkers,
            resmarkers_amplicon = resmarkers_amplicon,
    }

    output {
        File resmarkers_file = build_resmarker_info_and_resistance_table.resmarkers_file
        File resmarkers_output = build_resmarker_info_and_resistance_table.resmarkers_output
        File resmarkers_by_locus = build_resmarker_info_and_resistance_table.resmarkers_by_locus
        File microhaps = build_resmarker_info_and_resistance_table.microhaps
        File new_mutations = build_resmarker_info_and_resistance_table.new_mutations
    }
}