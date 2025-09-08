task build_resistance_table {
  input {
    File alleledata
    File alignment_data
    File resmarkers
    File refseq
    Int n_cores # Should this be used in runtime?
    String docker_name = "your_docker_image"
  }

  command <<<
    python3 ./bin/resistance_marker_module.py \
      --allele_data_path ~{alleledata} \
      --aligned_asv_table_path ~{alignment_data} \
      --res_markers_info_path ~{resmarkers} \
      --refseq_path ~{refseq} \
      --n-cores ~{n_cores}
  >>>

  output {
    File resmarker_table = "resmarker_table.txt"
    File resmarker_table_by_locus = "resmarker_table_by_locus.txt"
    File microhaps = "resmarker_microhaplotype_table.txt"
    File new_mutations = "all_mutations_table.txt"
  }

  runtime {
    docker: docker_name
  }
}