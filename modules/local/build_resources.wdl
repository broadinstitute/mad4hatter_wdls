version 1.0

task build_amplicon_info {
  input {
    Array[String] pools
    Array[String] amplicon_info_paths
    File amplicon_info_output
    String docker_name = "your_docker_image"
  }

  command <<<
    python3 /bin/build_amplicon_info.py \
      --pools ~{pools} \
      --amplicon_info_paths ~{amplicon_info_paths} \
      --amplicon_info_output_path ~{amplicon_info_output}
  >>>

  output {
    File amplicon_info = "~{amplicon_info_output}"
  }

  runtime {
    docker: docker_name
  }
}

task build_targeted_reference {
  input {
    File reference_input_paths
    File reference_output_path
    String docker_name = "your_docker_image"
  }

  command <<<
    python3 /bin/merge_fasta.py \
      --reference_paths ~{reference_input_paths} \
      --reference_output_path ~{reference_output_path}
  >>>

  output {
    File reference_fasta = "~{reference_output_path}"
  }

  runtime {
    docker: docker_name
  }
}

task build_resmarker_info {
  input {
    File amplicon_info
    #TODO: This file is https://github.com/EPPIcenter/mad4hatter/blob/update_dockerfile/panel_information/principal_resistance_marker_info_table.tsv
    #TODO: It should be added to updated docker file and we should ensure path is correct
    File principal_resmarkers = "principal_resistance_marker_info_table.tsv"
    File resmarker_info_output_path
    String docker_name = "your_docker_image"
  }

  command <<<
    python3 /bin/build_resmarker_info.py \
      --amplicon_info ~{amplicon_info} \
      --principal_resmarkers ~{principal_resmarkers} \
      --resmarker_info_output_path ~{resmarker_info_output_path}
  >>>

  output {
    File resmarker_info = "~{resmarker_info_output_path}"
  }

  runtime {
    docker: docker_name
  }
}