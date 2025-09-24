version 1.0

# Denoise the demultiplexed amplicon fastq
task dada2_analysis {
  input {
    Array[File] demultiplexed_dir_tars
    File amplicon_info
    String dada2_pool
    Int band_size
    Float omega_a
    Int maxEE
    Boolean just_concatenate
    Int cpus = 1
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  Int estimated_compression_ratio = 5  # Typical compression ratio for genomic data
  Int disk_size_gb = ceil(estimated_compression_ratio * size(demultiplexed_dir_tars, "GB")) + 20
  Int memory_gb = 8

  command <<<
  set -euo pipefail

  # Create directory to extract tars
  mkdir -p extracted_dirs

  # Untar all the directories and collect the paths to the directories containing fastq files
  DIRS=""
  for tar_file in ~{sep=" " demultiplexed_dir_tars}; do
    dir_name=$(basename "$tar_file" .tar.gz)
    mkdir -p "extracted_dirs/$dir_name"
    tar -xf "$tar_file" --no-xattrs -C "extracted_dirs/$dir_name"
    # Remove tar file after successful extraction
    rm "$tar_file"

    # Find all directories named demultiplexed_fastqs in the extracted content
    fastq_dirs=$(find "extracted_dirs/$dir_name" -type d -name "demultiplexed_fastqs")
    for dir in $fastq_dirs; do
      DIRS="$DIRS $dir"
    done
  done

  Rscript /opt/mad4hatter/bin/dada_overlaps.R \
    --trimmed-path $DIRS \
    --ampliconFILE ~{amplicon_info} \
    --pool ~{dada2_pool} \
    --band-size ~{band_size} \
    --omega-a ~{omega_a} \
    --maxEE ~{maxEE} \
    --cores ~{cpus} \
    ~{if just_concatenate then "--concat-non-overlaps" else ""}
  >>>

  output {
    File dada2_clusters = "dada2.clusters.txt"
  }

  runtime {
    docker: "~{docker_image}"
    cpu: cpus
    memory: "~{memory_gb}G"
    disk: "~{disk_size_gb}GB"
  }
}