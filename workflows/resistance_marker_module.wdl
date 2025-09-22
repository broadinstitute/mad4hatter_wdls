version 1.0

import "../modules/local/build_resistance_table.wdl" as build_resistance_table
import "../modules/local/build_resources.wdl" as build_resources

# This workflow is comprised of processes to build a table of resistance markers of interest.

workflow resistance_marker_module {
    input {
        File amplicon_info
        File allele_data
        File alignment_data
        File reference
        File resmarker_info
        String? resmarker_info
        String docker_image
    }

    if (!defined(resmarker_info))  {
        call build_resources.build_resmarker_info {
            input:
                amplicon_info = amplicon_info,
                principal_resmarkers = resmarker_info,
                resmarker_info_output_path = "resmarker_info.tsv"
        }
    }

    call build_resistance_table.build_resistance_table {
        input:
            alleledata = allele_data,
            alignment_data = alignment_data,
            resmarkers = select_first([resmarker_info, build_resmarker_info.resmarker_info]),
            refseq = reference,
            docker_image = docker_image
    }

}