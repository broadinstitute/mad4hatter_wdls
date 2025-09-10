version 1.0

import "../modules/local/dada2_analysis.wdl" as dada2_analysis

workflow denoise_amplicons_1 {
  input {
    File amplicon_info
    Array[File] demultiplexed_fastqs
    String dada2_pool
    Int band_size
    Float omega_a
    Int maxEE
    Boolean just_concatenate
    String docker_image = "your_docker_image"
  }

  call dada2_analysis.dada2_analysis {
    input:
      demultiplexed_fastqs = demultiplexed_fastqs,
      amplicon_info = amplicon_info,
      dada2_pool = dada2_pool,
      band_size = band_size,
      omega_a = omega_a,
      maxEE = maxEE,
      just_concatenate = just_concatenate,
      docker_image = docker_image
  }

  output {
    File dada2_clusters = dada2_analysis.dada2_clusters
  }
}