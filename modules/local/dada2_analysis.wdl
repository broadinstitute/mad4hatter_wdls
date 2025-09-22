version 1.0

# Denoise the demultiplexed amplicon fastq
task dada2_analysis {
  input {
    Array[File] demultiplexed_fastqs
    File amplicon_info

    String dada2_pool
    Int band_size
    Float omega_a
    Int maxEE
    Boolean just_concatenate

    Int cpus = 1
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  command <<<
  set -euo pipefail

  CONCATENATE_FLAG=""
  if [[ ~{just_concatenate} == "true" ]]; then
    CONCATENATE_FLAG="--concat-non-overlaps"
  fi

  Rscript /opt/mad4hatter/bin/dada_overlaps.R \
    --trimmed-path ~{sep=" " prefix(demultiplexed_fastqs, " dirname ")} \
    --ampliconFILE ~{amplicon_info} \
    --pool ~{dada2_pool} \
    --band-size ~{band_size} \
    --omega-a ~{omega_a} \
    --maxEE ~{maxEE} \
    --cores ~{cpus} \
    $CONCATENATE_FLAG
  >>>

  output {
    File dada2_clusters = "dada2.clusters.txt"
  }

  runtime {
    docker: "~{docker_image}"
    cpu: cpus
    memory: "8G"
  }
}