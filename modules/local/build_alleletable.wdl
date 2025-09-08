task build_alleletable {
  input {
    File amplicon_info
    File denoised_asvs
    File processed_asvs
    String docker_name = "your_docker_image"
  }

  command <<<
    Rscript ./bin/build_alleletable.R \
      --amplicon-info ~{amplicon_info} \
      --denoised-asvs ~{denoised_asvs} \
      --processed-asvs ~{processed_asvs}
  >>>

  output {
    File allele_data = "allele_data.txt"
  }

  runtime {
    docker: docker_name
  }
}