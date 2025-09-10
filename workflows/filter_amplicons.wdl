version 1.0

#TODO: The imported module does not exist and
#TODO: in nextflow it is not clear where it is imported from
#TODO: https://github.com/EPPIcenter/mad4hatter/blob/develop/workflows/filter_amplicons.nf

import "../modules/local/dada2_filtering.wdl" as dada2_filtering

workflow filter_amplicons {
  input {
    Array[File] demultiplexed_fastqs
    Int minLen
    Int maxN
    Boolean rm_phix
    Boolean compress
    Boolean matchIDs
    Float maxEE_R1
    Int truncQ_R1
    Int trimRight_R1
    Int trimLeft_R1
    Float maxEE_R2
    Int truncQ_R2
    Int trimRight_R2
    Int trimLeft_R2
    String docker_string = "my_docker"
  }

  # Step 1: dada2_preprocessing
  call dada2_filtering.dada2_filtering {
    input:
      demultiplexed_fastqs = demultiplexed_fastqs,
      minLen = minLen,
      maxN = maxN,
      rm_phix = rm_phix,
      compress = compress,
      matchIDs = matchIDs,
      maxEE_R1 = maxEE_R1,
      truncQ_R1 = truncQ_R1,
      trimRight_R1 = trimRight_R1,
      trimLeft_R1 = trimLeft_R1,
      maxEE_R2 = maxEE_R2,
      truncQ_R2 = truncQ_R2,
      trimRight_R2 = trimRight_R2,
      trimLeft_R2 = trimLeft_R2,
      docker_string = docker_string
  }

  output {
    Array[File] dada_filtFs_ch = dada2_filtering.filtFs
    Array[File] dada_filtRs_ch = dada2_filtering.filtRs
    File dada_filter_metadata_ch = dada2_filtering.filter_metadata
  }
}