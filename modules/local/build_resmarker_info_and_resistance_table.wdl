version 1.0

task build_resmarker_info_and_resistance_table {
    input {
        File alleledata
        File alignment_data
        File refseq
        File amplicon_info_ch
        File? principal_resmarkers
        File? resmarkers_amplicon
        String? resmarker_info_output_path = "resmarker_info.tsv"
        Int cpus = 4
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # TODO: add check here: if use_remarker_amplicon is true, then resmarkers_amplicon must be provided

    command <<<
        echo "Running build_resmarker_info.py"
        python3 /opt/mad4hatter/bin/build_resmarker_info.py \
            --amplicon_info ~{amplicon_info_ch} \
            --principal_resmarkers ~{select_first([principal_resmarkers, "/opt/mad4hatter/panel_information/principal_resistance_marker_info_table.tsv"])} \
            --resmarker_info_output_path ~{resmarker_info_output_path}

        echo "Running resistance_marker_module.py"
        python3 /opt/mad4hatter/bin/resistance_marker_module.py \
            --allele_data_path ~{alleledata} \
            --aligned_asv_table_path ~{alignment_data} \
            --res_markers_info_path ~{select_first([resmarkers_amplicon, resmarker_info_output_path])} \
            --refseq_path ~{refseq} \
            --n-cores ~{cpus}
    >>>

    output {
        File resmarkers_file = select_first([resmarkers_amplicon, resmarker_info_output_path])
        File resmarkers_output = "resmarker_table.txt"
        File resmarkers_by_locus = "resmarker_table_by_locus.txt"
        File microhaps = "resmarker_microhaplotype_table.txt"
        File new_mutations = "all_mutations_table.txt"
    }

    runtime {
        docker: docker_image
        cpu: cpus
    }
}