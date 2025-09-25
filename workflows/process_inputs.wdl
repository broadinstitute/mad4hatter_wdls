version 1.0

import "../modules/local/build_resources.wdl" as build_resources

workflow generate_amplicon_info {
  input {
    Array[File] amplicon_info
    Array[String] pools
    String project_dir
    String docker_image
  }

  call build_resources.build_amplicon_info {
    input:
      pools = pools,
      amplicon_info_paths = amplicon_info,
      docker_image = docker_image
  }

  output {
    File amplicon_info_ch = build_amplicon_info.amplicon_info
  }
}

workflow concatenate_targeted_reference {
  input {
    Array[File] reference_input_paths
    String docker_image
  }

  call build_resources.build_targeted_reference {
    input:
      reference_input_paths = select_first([reference_input_paths]),
      docker_image = docker_image
  }

  output {
    File reference_fasta = build_targeted_reference.reference_fasta
  }
}
