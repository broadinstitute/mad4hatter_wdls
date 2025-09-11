version 1.0

import "../modules/local/build_resources.wdl" as build_resources
import "../modules/local/quality_control.wdl" as quality_control


workflow generate_amplicon_info {
  input {
    Array[String] pools
    Map[String, String] pool_options
    String project_dir
  }

  # Resolve paths for each pool
  Array[String] amplicon_info_paths = [for pool in pools: project_dir + "/" + pool_options[pool] + ".amplicon_info_path"]
  # TODO I don't think this is correct - need to check with Kathryn about where params.pool_options is coming from
  String amplicon_info_paths_str = sep(" ", amplicon_info_paths)
  String selected_pools_str = sep(" ", pools)

  call build_resources.build_amplicon_info {
    input:
      pools = selected_pools_str,
      amplicon_info_paths = amplicon_info_paths_str,
      amplicon_info_output = "amplicon_info.tsv"
  }

  output {
    File amplicon_info_ch = build_amplicon_info.amplicon_info
  }

}

workflow concatenate_targeted_reference {
  input {
    Array[String] pools
    Map[String, String] pool_options
    String project_dir
  }

  # TODO I don't think this is correct - need to check with Kathryn about where params.pool_options is coming from
  Array[String] targeted_reference_paths = [
    for pool in pools: project_dir + "/" + pool_options[pool] + ".targeted_reference_path"
  ]

  String targeted_reference_paths_str = sep(" ", targeted_reference_paths)

  call build_resources.build_targeted_reference {
    input:
      reference_input_paths = targeted_reference_paths_str,
      reference_output_path = "reference.fasta"
  }

  output {
    File reference_fasta = build_targeted_reference.reference_fasta
  }
}
