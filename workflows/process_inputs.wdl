version 1.0

import "../modules/local/build_resources.wdl" as build_resources
import "../modules/local/quality_control.wdl" as quality_control

struct PoolConfig {
  String amplicon_info_path
  String targeted_reference_path
}

workflow generate_amplicon_info {
  input {
    Array[String] pools
    String project_dir
    String docker_image
  }

  # TODO: This need to get added to the docker and update path?
  Map[String, PoolConfig] pool_options = read_json("../conf/pool_config.json")

  # Check each pool exists in pool_options
  scatter (pool in pools) {
    Boolean pool_exists = defined(read_pool_configs.pool_options[pool])
    if (!pool_exists) {
      call error_with_message {
        input: message = "Pool '${pool}' not found in configuration."
      }
    }

  Array[String] amplicon_info_paths = [for pool in pools: "${project_dir}/${read_pool_configs.pool_options[pool].amplicon_info_path}"]
  String amplicon_info_paths_str = sep(" ", amplicon_info_paths)
  String selected_pools_str = sep(" ", pools)

  call build_resources.build_amplicon_info {
    input:
      pools = selected_pools_str,
      amplicon_info_paths = amplicon_info_paths_str,
      amplicon_info_output = "amplicon_info.tsv",
      docker_image = docker_image
  }

  output {
    File amplicon_info_ch = build_amplicon_info.amplicon_info
  }
}

workflow concatenate_targeted_reference {
  input {
    Array[String] pools
    String project_dir
  }

  # TODO: This need to get added to the docker and update path?
  Map[String, PoolConfig] pool_options = read_json("../conf/pool_config.json")

  # Check each pool exists in pool_options
  scatter (pool in pools) {
    Boolean pool_exists = defined(read_pool_configs.pool_options[pool])
    if (!pool_exists) {
      call error_with_message {
        input: message = "Pool '${pool}' not found in configuration."
      }
    }

  Array[String] targeted_reference_paths = [for pool in pools: "${project_dir}/${read_pool_configs.pool_options[pool].targeted_reference_path}"]
  String targeted_reference_paths_str = sep(" ", targeted_reference_paths)

  String targeted_reference_paths_str = sep(" ", targeted_reference_paths)

  call build_resources.build_targeted_reference {
    input:
      reference_input_paths = targeted_reference_paths_str,
      reference_output_path = "reference.fasta",
      docker_image = docker_image
  }

  output {
    File reference_fasta = build_targeted_reference.reference_fasta
  }
}
