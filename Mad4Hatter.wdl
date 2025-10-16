version 1.0

import "workflows/demultiplex_amplicons.wdl" as DemultiplexAmpliconsWf
import "workflows/denoise_amplicons_1.wdl" as DenoiseAmplicons1Wf
import "workflows/denoise_amplicons_2.wdl" as DenoiseAmplicons2Wf
import "workflows/resistance_marker_module.wdl" as ResistanceMarkerModuleWf
import "workflows/quality_control.wdl" as QualityControlWf
import "workflows/process_inputs.wdl" as ProcessInputsWf
import "modules/local/build_alleletable.wdl" as BuildAlleletable
import "modules/local/move_outputs.wdl" as MoveOutputs
import "modules/local/error_with_message.wdl" as ErrorWithMessage

## MAD4HatTeR Main Workflow
##
## This is the main workflow for MAD4HatTeR (Malaria Amplicon Deep-sequencing for Haplotype and Target Resistance)
## pipeline. It processes amplicon sequencing data through demultiplexing, denoising, quality control,
## and resistance marker analysis.


workflow MAD4HatTeR {
    input {
        Array[String] pools
        String sequencer # The sequencer used to produce your data
        Array[File] left_fastqs # List of left fastqs. Must be in correct order.
        Array[File] right_fastqs # List of right fastqs. Must be in correct order.
        Array[File] amplicon_info_files
        Float omega_a = 0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001 # Level of statistical evidence required for DADA2 to infer a new ASV
        String dada2_pool = "pseudo" # Pooling method for DADA2 to process ASVs [Options: pseudo (default), true, false]
        Int band_size = 16 # Limit on the net cumulative number of insertions of one sequence relative to the other in DADA2
        Int max_ee = 3 # Limit on number of expected errors within a read during filtering and trimming within DADA2
        File? refseq_fasta # Path to targeted reference sequences (optional, auto-generated if not provided)
        Int cutadapt_minlen = 100
        Int allowed_errors = 0
        Boolean just_concatenate = false
        Boolean mask_tandem_repeats = true
        Boolean mask_homopolymers = true
        File? masked_fasta
        File? principal_resmarkers
        File? resmarkers_info_tsv
        String output_cloud_directory
        Int dada2_cpus = 2
        Int dada2_memory_multiplier = 1
        Int dada2_space_multiplier = 1
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Use sub() with a regular expression to check for the prefix.
    # This pattern matches the entire string if it starts with "gs://".
    # If the pattern is found, a non-empty string is returned.
    # If the pattern is not found, the original string is returned.
    String matches_prefix = sub(output_cloud_directory, "^gs://.*", "MATCH")

    # Use a boolean variable to convert the string result to a boolean.
    # "MATCH" will be true, while any other string will be false.
    Boolean starts_with_gs = matches_prefix == "MATCH"

    # Use a conditional call to execute the ErrorWithMessage task
    # if the condition is false.
    if (!starts_with_gs) {
        call ErrorWithMessage.error_with_message {
            input:
                message = "ERROR: The output_cloud_directory directory does not start with 'gs://'."
        }
    }

    # Generate final amplicon info
    call ProcessInputsWf.generate_amplicon_info {
        input:
            pools = pools,
            docker_image = docker_image,
            amplicon_info_files = amplicon_info_files
    }

    # Step 1: Demultiplex amplicons by target region
    # This separates reads by amplicon target and performs initial quality filtering
    call DemultiplexAmpliconsWf.demultiplex_amplicons {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            left_fastqs = left_fastqs,
            right_fastqs = right_fastqs,
            sequencer = sequencer,
            cutadapt_minlen = cutadapt_minlen,
            allowed_errors = allowed_errors,
            docker_image = docker_image
    }

    # Step 2: First denoising step using DADA2
    # This performs error correction, dereplication, and initial ASV inference
    call DenoiseAmplicons1Wf.denoise_amplicons_1 {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            demultiplexed_dir_tars = demultiplex_amplicons.demux_fastqs_ch,
            dada2_pool = dada2_pool,
            band_size = band_size,
            omega_a = omega_a,
            max_ee = max_ee,
            just_concatenate = just_concatenate,
            dada2_cpus = dada2_cpus,
            dada2_memory_multiplier = dada2_memory_multiplier,
            dada2_space_multiplier = dada2_space_multiplier,
            docker_image = docker_image
    }

    # Step 3: Second denoising step with masking and collapsing
    # This performs sequence masking, collapses similar ASVs, and creates final ASV table
    call DenoiseAmplicons2Wf.denoise_amplicons_2 {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            clusters = denoise_amplicons_1.dada2_clusters,
            just_concatenate = just_concatenate,
            refseq_fasta = refseq_fasta,
            masked_fasta = masked_fasta,
            mask_tandem_repeats = mask_tandem_repeats,
            mask_homopolymers = mask_homopolymers,
            docker_image = docker_image
    }

    # Step 4: Build final allele table
    # This creates the comprehensive allele frequency table combining all samples and amplicons
    call BuildAlleletable.build_alleletable {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            denoised_asvs = denoise_amplicons_1.dada2_clusters,
            processed_asvs = denoise_amplicons_2.results_ch,
            docker_image = docker_image
    }

    # Step 5: Generate quality control report
    # This creates comprehensive QC metrics and visualizations for the entire run
    call QualityControlWf.quality_control {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            sample_coverage_files = demultiplex_amplicons.sample_summary_ch,
            amplicon_coverage_files = demultiplex_amplicons.amplicon_summary_ch,
            alleledata = build_alleletable.alleledata,
            clusters = denoise_amplicons_1.dada2_clusters,
            docker_image = docker_image
    }

    # Step 6: Resistance marker analysis
    # This identifies and analyzes known resistance markers in the final ASV data
    call ResistanceMarkerModuleWf.resistance_marker_module {
        input:
            allele_data = build_alleletable.alleledata,
            alignment_data = denoise_amplicons_2.aligned_asv_table,
            reference = denoise_amplicons_2.reference_ch,
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            principal_resmarkers = principal_resmarkers,
            resmarkers_info_tsv = resmarkers_info_tsv,
            docker_image = docker_image
    }

    call MoveOutputs.move_outputs {
        input:
            output_cloud_directory = output_cloud_directory,
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            final_allele_table = build_alleletable.alleledata,
            sample_coverage = quality_control.sample_coverage,
            amplicon_coverage = quality_control.amplicon_coverage,
            dada2_clusters = denoise_amplicons_1.dada2_clusters,
            resmarkers_output = resistance_marker_module.resmarkers_output,
            resmarkers_by_locus = resistance_marker_module.resmarkers_by_locus,
            microhaps = resistance_marker_module.microhaps,
            new_mutations = resistance_marker_module.new_mutations,
            reference_fasta = denoise_amplicons_2.reference_ch,
            resmarkers_file = resistance_marker_module.resmarkers_file,
    }

    output {
        String final_allele_table_cloud_path = move_outputs.final_allele_table_cloud_path
        String sample_coverage_cloud_path = move_outputs.sample_coverage_cloud_path
        String amplicon_coverage_cloud_path = move_outputs.amplicon_coverage_cloud_path
        String dada2_clusters_cloud_path = move_outputs.dada2_clusters_cloud_path
        String resmarkers_output_cloud_path = move_outputs.resmarkers_output_cloud_path
        String resmarkers_by_locus_cloud_path = move_outputs.resmarkers_by_locus_cloud_path
        String microhaps_cloud_path = move_outputs.microhaps_cloud_path
        String new_mutations_cloud_path = move_outputs.new_mutations_cloud_path
        String amplicon_info_cloud_path = move_outputs.amplicon_info_cloud_path
        String reference_fasta_cloud_path = move_outputs.reference_fasta_cloud_path
        String resmarkers_file_cloud_path = move_outputs.resmarkers_file_cloud_path
    }
}