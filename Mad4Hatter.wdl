version 1.0

## MAD4HatTeR Main Workflow
##
## This is the main workflow for MAD4HatTeR (Malaria Amplicon Deep-sequencing for Haplotype and Target Resistance)
## pipeline. It processes amplicon sequencing data through demultiplexing, denoising, quality control,
## and resistance marker analysis.

# Import all required workflows and modules
import "workflows/demultiplex_amplicons.wdl" as DemultiplexAmpliconsWf
import "workflows/denoise_amplicons_1.wdl" as DenoiseAmplicons1Wf
import "workflows/denoise_amplicons_2.wdl" as DenoiseAmplicons2Wf
import "workflows/resistance_marker_module.wdl" as ResistanceMarkerModuleWf
import "workflows/quality_control.wdl" as QualityControlWf
import "workflows/process_inputs.wdl" as ProcessInputsWf
#import "workflows/validate_inputs.wdl" as ValidateInputsWf
import "workflows/qc_only.wdl" as QcOnlyWf
import "workflows/postproc_only.wdl" as PostprocOnlyWf
import "modules/local/build_alleletable.wdl" as BuildAlleletable

## Main MAD4HatTeR workflow
workflow MAD4HatTeR {
  input {
    ## MANDATORY ARGUMENTS
    Array[String] pools

    # The sequencer used to produce your data [Options: miseq, nextseq]
    String sequencer

    ## WORKFLOW-SPECIFIC MANDATORY ARGUMENTS
    # List of fastqs. Must be in correct order.
    Array[File] left_fastqs
    Array[File] right_fastqs

    # amplicon info files
    Array[File] amplicon_info_files

    ## DADA2 PARAMETERS
    # Level of statistical evidence required for DADA2 to infer a new ASV
    Float omega_a = 0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001

    # Pooling method for DADA2 to process ASVs [Options: pseudo (default), true, false]
    String dada2_pool = "pseudo"

    # Limit on the net cumulative number of insertions of one sequence relative to the other in DADA2
    Int band_size = 16

    # Limit on number of expected errors within a read during filtering and trimming within DADA2
    Int maxEE = 3

    # Path to targeted reference sequences (optional, auto-generated if not provided)
    File? refseq_fasta

    File clusters
    Int cutadapt_minlen = 100
    Int allowed_errors = 0
    Boolean just_concatenate = false
    Boolean mask_tandem_repeats = true
    Boolean mask_homopolymers = true
    File? masked_fasta
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  # Validate inputs first - this ensures all required parameters are present and valid
  #TODO: This does not exist, create or add validation here.
  #call ValidateInputsWf.validate_inputs {
  #  input:
  #    pools = pools,
  #    sequencer = sequencer,
  #    workflow_type = workflow_type,
  #    read_pairs = read_pairs,
  #    denoised_asvs = denoised_asvs,
  #    docker_image = docker_image
  #}

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
      maxEE = maxEE,
      just_concatenate = just_concatenate,
      docker_image = docker_image
  }

  # Step 3: Second denoising step with masking and collapsing
  # This performs sequence masking, collapses similar ASVs, and creates final ASV table
  call DenoiseAmplicons2Wf.denoise_amplicons_2 {
    input:
      amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
      clusters = clusters,
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
      amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
      allele_data = build_alleletable.alleledata,
      alignment_data = denoise_amplicons_2.aligned_asv_table,
      reference = denoise_amplicons_2.reference_ch,
      docker_image = docker_image
  }

  ## OUTPUT DEFINITIONS
  output {
    File final_allele_table = build_alleletable.alleledata
    File sample_coverage_out = quality_control.sample_coverage_out
    File amplicon_coverage_out = quality_control.amplicon_coverage_out
    Array[File] quality_reports = quality_control.quality_reports
    File dada2_clusters = denoise_amplicons_1.dada2_clusters
    File resmarkers_output = resistance_marker_module.resmarkers_output
    File resmarkers_by_locus = resistance_marker_module.resmarkers_by_locus
    File microhaps = resistance_marker_module.microhaps
    File new_mutations = resistance_marker_module.new_mutations
    File amplicon_info_ch = generate_amplicon_info.amplicon_info_ch
    File reference_fasta = denoise_amplicons_2.reference_ch
    File resmarker_info = resistance_marker_module.resmarkers_amplicon
  }
}