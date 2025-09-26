version 1.0

task build_amplicon_info {
  input {
    Array[String] pools
    Array[File] amplicon_info_paths
    String? amplicon_info_output = "amplicon_info.tsv"
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
    python3 /opt/mad4hatter/bin/build_amplicon_info.py \
      --pools ~{sep=' ' pools} \
      --amplicon_info_paths ~{sep=' ' amplicon_info_paths} \
      --amplicon_info_output_path ~{amplicon_info_output}
  >>>

  output {
    File amplicon_info = "~{amplicon_info_output}"
  }

  runtime {
    docker: docker_image
  }
}

task build_targeted_reference {
  input {
    Array[File] reference_input_paths
    String? reference_output_path = "reference.fasta"
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
    python3 /opt/mad4hatter/bin/merge_fasta.py \
      --reference_paths ~{sep=' ' reference_input_paths} \
      --reference_output_path ~{reference_output_path}
  >>>

  output {
    File reference_fasta = "~{reference_output_path}"
  }

  runtime {
    docker: docker_image
  }
}

task build_resmarker_info {
  input {
    File amplicon_info
    # TODO: This file is located here: https://github.com/EPPIcenter/mad4hatter/blob/update_dockerfile/panel_information/principal_resistance_marker_info_table.tsv
    # TODO: It should be added to updated docker file and we should ensure path is correct (currently located in theworkspace bucket)
    File principal_resmarkers
    String? resmarker_info_output_path = "resmarker_info.tsv"
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
    python3 /opt/mad4hatter/bin/build_resmarker_info.py \
      --amplicon_info ~{amplicon_info} \
      --principal_resmarkers ~{principal_resmarkers} \
      --resmarker_info_output_path ~{resmarker_info_output_path}
  >>>

  output {
    File resmarker_info = "~{resmarker_info_output_path}"
  }

  runtime {
    docker: docker_image
    memory: "8G"
    cpu: 1
    disks: "local-disk 10 HDD"

  }
}