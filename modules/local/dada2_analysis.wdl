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
        Int cpus = 4
        Int free_cpus = 2
        Int memory_multiplier = 1
        Int? space_gb
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Typical compression ratio for genomic data
    Int estimated_compression_ratio = 5
    # Calculate total size of all tar files in the array
    Int tar_files_size = ceil(size(demultiplexed_dir_tars, "GB"))
    Int dynamic_disk_size_gb = (tar_files_size * estimated_compression_ratio + 50)
    Int disk_size_gb = select_first([space_gb, dynamic_disk_size_gb])
    Int memory_gb = 8 * memory_multiplier
    Int total_tar_file = length(demultiplexed_dir_tars)
    # If free_cpus is greater than cpus, use cpus, else use cpus - free_cpus
    Int n_cores = if cpus > free_cpus then cpus - free_cpus else cpus
    # If cpus is less than free_cpus, use cpus + free_cpus else use cpus
    Int used_cpus = if cpus < free_cpus then cpus + free_cpus else cpus

    command <<<
        set -euo pipefail

        START_TIME=$(date +%s)
        timestamp() {
            local now=$(date +%s)
            local elapsed=$((now - START_TIME))
            printf '%02d:%02d:%02d' $((elapsed/3600)) $(((elapsed%3600)/60)) $((elapsed%60))
        }

        echo "$(timestamp) : Memory allocated: ~{memory_gb} GB"
        echo "$(timestamp) : Disk space allocated: ~{disk_size_gb} GB"
        echo "$(timestamp) : Total size of all tar files: ~{tar_files_size} GB"
        echo "$(timestamp) : Total number of tar files: ~{total_tar_file}"
        echo "$(timestamp) : CPUs allocated: ~{used_cpus}"


        # Create directory to extract tars
        mkdir -p extracted_dirs

        # Untar all the directories and collect the paths to the directories containing fastq files
        touch fastq_dirs.txt
        echo "$(timestamp) : Looping through tar files to extract fastq.gz files"
        tar_counter=0
        for tar_file in ~{sep=" " demultiplexed_dir_tars}; do
            dir_name=$(basename "$tar_file" .tar.gz)_$tar_counter
            mkdir -p "extracted_dirs/$dir_name"
            tar -xf "$tar_file" --no-xattrs -C "extracted_dirs/$dir_name"
            # Remove tar file after successful extraction
            tar_counter=$((tar_counter + 1))

            # Find all directories containing fastq.gz files anywhere in the extracted content
            find "extracted_dirs/$dir_name" -type f -name "*.fastq.gz" | xargs -n1 dirname | sort -u >> fastq_dirs.txt
        done

        echo "$(timestamp) : Finished extracting all tar files."
        # Create a sorted unique list of directories
        DIRS=$(sort -u fastq_dirs.txt | tr '\n' ' ')

        echo "$(timestamp) : Directories with fastq files to be processed:"
        echo $DIRS

        Rscript /opt/mad4hatter/bin/dada_overlaps.R \
            --trimmed-path $DIRS \
            --ampliconFILE ~{amplicon_info_ch} \
            --pool ~{dada2_pool} \
            --band-size ~{band_size} \
            --omega-a ~{omega_a} \
            --maxEE ~{max_ee} \
            --cores ~{n_cores} \
            ~{if just_concatenate then "--concat-non-overlaps" else ""}
        echo "$(timestamp) : DADA2 processing complete."
    >>>

    output {
        File dada2_clusters = "dada2.clusters.txt"
    }

    runtime {
        docker: docker_image
        cpu: used_cpus
        cpuPlatform: "Intel Ice Lake"
        memory: memory_gb + " GB"
        disks: "local-disk " + disk_size_gb + " LOCAL"
    }
}