version 1.0

import "./denoise_amplicons_2.wdl" as denoise_amplicons_2
import "../modules/local/build_alleletable.wdl" as build_alleletable

workflow postproc_only {
  input {
    File amplicon_info_ch
    File clusters
    Boolean just_concatenate
    Boolean mask_tandem_repeats
    Boolean mask_homopolymers
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  # Call the denoise_amplicons_2 workflow
  call denoise_amplicons_2.denoise_amplicons_2 {
    input:
      amplicon_info_ch = amplicon_info_ch,
      clusters = clusters,
      just_concatenate = just_concatenate,
      mask_tandem_repeats = mask_tandem_repeats,
      mask_homopolymers = mask_homopolymers,
      docker_image = docker_image
  }

  # Call the build_alleletable task
  call build_alleletable.build_alleletable {
    input:
      amplicon_info_ch = amplicon_info_ch,
      denoised_asvs = clusters,
      processed_asvs = denoise_amplicons_2.results_ch,
      docker_image = docker_image
  }

  output {
    File reference_ch = denoise_amplicons_2.reference_ch
    File aligned_asv_table = denoise_amplicons_2.aligned_asv_table
    File alleledata = build_alleletable.alleledata
  }
}