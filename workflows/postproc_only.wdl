version 1.0

import "./denoise_amplicons_2.wdl" as denoise_amplicons_2
import "../modules/local/build_alleletable.wdl" as build_alleletable

workflow postproc_only {
  input {
    File amplicon_info
    File denoised_asvs
    String docker_string = "my_docker"
  }

  # Call the denoise_amplicons_2 workflow
  call denoise_amplicons_2.denoise_amplicons_2 {
    input:
      amplicon_info = amplicon_info,
      denoise_ch = denoised_asvs,
      just_concatenate = false,
      mask_tandem_repeats = true,
      mask_homopolymers = true,
      docker_string = docker_string
  }

  # Call the build_alleletable task
  call build_alleletable.build_alleletable {
    input:
      amplicon_info = amplicon_info,
      denoise_ch = denoised_asvs,
      results_ch = denoise_amplicons_2.results_ch,
      docker_string = docker_string
  }
}