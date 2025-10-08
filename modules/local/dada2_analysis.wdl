version 1.0

# Denoise the demultiplexed amplicon fastq
task dada2_analysis {
    input {
        Array[File] demultiplexed_dir_tars
        File amplicon_info_ch
        String dada2_pool
        Int band_size
        Float omega_a
        Int max_ee
        Boolean just_concatenate
        Int cpus = 2
        Int dada2_memory_multiplier = 1
        Int dada2_space_multiplier = 1
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Typical compression ratio for genomic data
    Int estimated_compression_ratio = 5
    Int size_amplicon_info = size(amplicon_info_ch, "GB")
    # Calculate total size of all tar files in the array
    Int tar_files_size = ceil(size(demultiplexed_dir_tars, "GB"))
    Int disk_size_gb = max(ceil((estimated_compression_ratio * tar_files_size + size_amplicon_info + 50)) * dada2_space_multiplier, 500)
    Int memory_gb = 16 * dada2_memory_multiplier

    command <<<
        set -euo pipefail

        echo "Memory allocated: ~{memory_gb}G"
        echo "Disk space allocated: ~{disk_size_gb}GB"
        echo "Size of amplicon info file: ~{size_amplicon_info}GB"
        echo "Total size of tar files: ~{tar_files_size}GB"
        echo "CPUs allocated: ~{cpus}"


        # Create directory to extract tars
        mkdir -p extracted_dirs

        # Untar all the directories and collect the paths to the directories containing fastq files
        touch fastq_dirs.txt
        echo "Looping through tar files to extract fastq.gz files"
        tar_counter=0
        for tar_file in ~{sep=" " demultiplexed_dir_tars}; do
            dir_name=$(basename "$tar_file" .tar.gz)_$tar_counter
            mkdir -p "extracted_dirs/$dir_name"
            echo "Extracting $tar_file to extracted_dirs/$dir_name"
            tar -xf "$tar_file" --no-xattrs -C "extracted_dirs/$dir_name"
            # Remove tar file after successful extraction
            rm "$tar_file"
            tar_counter=$((tar_counter + 1))
            echo "Extraction complete"

            # Find all directories containing fastq.gz files anywhere in the extracted content
            find "extracted_dirs/$dir_name" -type f -name "*.fastq.gz" | xargs -n1 dirname | sort -u >> fastq_dirs.txt
        done

        echo "Finished extracting all tar files."
        # Create a sorted unique list of directories
        DIRS=$(sort -u fastq_dirs.txt | tr '\n' ' ')

        echo "Directories with fastq files to be processed:"
        echo $DIRS

        Rscript /opt/mad4hatter/bin/dada_overlaps.R \
            --trimmed-path $DIRS \
            --ampliconFILE ~{amplicon_info_ch} \
            --pool ~{dada2_pool} \
            --band-size ~{band_size} \
            --omega-a ~{omega_a} \
            --maxEE ~{max_ee} \
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