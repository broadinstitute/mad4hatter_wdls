version 1.0

task move_outputs {
    input {
        File final_allele_table
        File sample_coverage
        File amplicon_coverage
        File dada2_clusters
        File resmarkers_output
        File resmarkers_by_locus
        File microhaps
        File new_mutations
        File amplicon_info_ch
        File reference_fasta
        File resmarkers_file
        String output_cloud_directory
    }

    # Remove trailing slashes from the output directory
    # This ensures consistent formatting for subsequent checks and operations.
    String sanitized_output_directory = sub(output_cloud_directory, "/+$", "")

    # Use sub() with a regular expression to check for the prefix.
    # This pattern matches the entire string if it starts with "gs://".
    # If the pattern is found, a non-empty string is returned.
    # If the pattern is not found, the original string is returned.
    String matches_prefix = sub(sanitized_output_directory, "^gs://.*", "MATCH")

    # Use a boolean variable to convert the string result to a boolean.
    # "MATCH" will be true, while any other string will be false.
    Boolean starts_with_gs = matches_prefix == "MATCH"

    command <<<
        set -e

        echo "Sanitized output directory: ~{sanitized_output_directory}"
        echo "Checking if output directory starts with 'gs://': ~{starts_with_gs}"

        if [ "~{starts_with_gs}" != "true" ]; then
            echo "ERROR: The output_cloud_directory directory does not start with 'gs://'."
            exit 1
        fi

        # Function to copy a file and echo its destination path
        copy_file() {
            local file=$1
            local filename=$(basename "$file")
            local destination="~{sanitized_output_directory}/$filename"
            echo "Copying $file to $destination"
            gcloud alpha storage cp "$file" "$destination"
        }

        # Copy individual files
        copy_file "~{final_allele_table}"
        copy_file "~{sample_coverage}"
        copy_file "~{amplicon_coverage}"
        copy_file "~{dada2_clusters}"
        copy_file "~{resmarkers_output}"
        copy_file "~{resmarkers_by_locus}"
        copy_file "~{microhaps}"
        copy_file "~{new_mutations}"
        copy_file "~{amplicon_info_ch}"
        copy_file "~{reference_fasta}"
        copy_file "~{resmarkers_file}"
    >>>

    output {
        String final_allele_table_cloud_path = sanitized_output_directory + "/" + basename(final_allele_table)
        String sample_coverage_cloud_path = sanitized_output_directory + "/" + basename(sample_coverage)
        String amplicon_coverage_cloud_path = sanitized_output_directory + "/" + basename(amplicon_coverage)
        String dada2_clusters_cloud_path = sanitized_output_directory + "/" + basename(dada2_clusters)
        String resmarkers_output_cloud_path = sanitized_output_directory + "/" + basename(resmarkers_output)
        String resmarkers_by_locus_cloud_path = sanitized_output_directory + "/" + basename(resmarkers_by_locus)
        String microhaps_cloud_path = sanitized_output_directory + "/" + basename(microhaps)
        String new_mutations_cloud_path = sanitized_output_directory + "/" + basename(new_mutations)
        String amplicon_info_cloud_path = sanitized_output_directory + "/" + basename(amplicon_info_ch)
        String reference_fasta_cloud_path = sanitized_output_directory + "/" + basename(reference_fasta)
        String resmarkers_file_cloud_path = sanitized_output_directory + "/" + basename(resmarkers_file)
    }

    runtime {
        docker: "gcr.io/google.com/cloudsdktool/cloud-sdk:540.0.0"
    }
}
