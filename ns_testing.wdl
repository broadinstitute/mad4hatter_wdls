version 1.0

import "modules/local/build_resistance_table.wdl" as BuildResistanceTable

# Can be used for testing subworkflows and modules
workflow BuildResistanceTableTest {
    input {
        File alleledata
        File alignment_data
        File resmarkers
        File refseq
        Int n_cores = 4
        String docker_name = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call BuildResistanceTable.build_resistance_table {
        input:
            alleledata = alleledata,
            alignment_data = alignment_data,
            resmarkers = resmarkers,
            refseq = refseq,
            n_cores = n_cores,
            docker_name = docker_name
    }

    output {
        File resmarkers_output = build_resistance_table.resmarkers_output
        File resmarkers_by_locus = build_resistance_table.resmarkers_by_locus
        File microhaps = build_resistance_table.microhaps
        File new_mutations = build_resistance_table.new_mutations
    }
}