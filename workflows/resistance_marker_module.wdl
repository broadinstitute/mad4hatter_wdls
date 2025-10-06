version 1.0

import "../modules/local/build_resistance_table.wdl" as build_resistance_table
import "../modules/local/build_resources.wdl" as build_resources

# This workflow is comprised of processes to build a table of resistance markers of interest.

workflow resistance_marker_module {
    input {
        File amplicon_info_ch
        File allele_data
        File alignment_data
        File reference
        File? resmarkers_amplicon
        String docker_image = "eppicenter/mad4hatter:develop"
    }


    call build_resources.build_resmarker_info {
        input:
            amplicon_info_ch = amplicon_info_ch,
            principal_resmarkers = resmarkers_amplicon,
            docker_image = docker_image
    }

    File resmarkers = select_first([build_resmarker_info.resmarker_info, resmarkers_amplicon])

    call build_resistance_table.build_resistance_table {
        input:
            alleledata = allele_data,
            alignment_data = alignment_data,
            resmarkers = resmarkers,
            refseq = reference,
            docker_image = docker_image
    }

    output {
        File resmarkers_output = build_resistance_table.resmarkers_output
        File resmarkers_by_locus = build_resistance_table.resmarkers_by_locus
        File microhaps = build_resistance_table.microhaps
        File new_mutations = build_resistance_table.new_mutations
        File resmarkers_file = resmarkers
    }
}