version 1.0

import "../modules/local/align_to_reference.wdl" as align_to_reference
import "../subworkflows/local/mask_low_complexity_regions.wdl" as mask_low_complexity_regions
import "../subworkflows/local/prepare_reference_sequences.wdl" as prepare_reference_sequences
import "../modules/local/build_pseudocigar.wdl" as build_pseudocigar
import "../modules/local/filter_asvs.wdl" as filter_asvs
import "../modules/local/collapse_concatenated_reads.wdl" as collapse_concatenated_reads

workflow denoise_amplicons_2 {
  input {
    File amplicon_info
    File denoise_ch
    Boolean just_concatenate
    File? refseq_fasta
    File? masked_fasta
    Boolean mask_tandem_repeats
    Boolean mask_homopolymers
    String docker_image = "my_docker"
  }

  # Process denoise_ch if just_concatenate is true
  if (just_concatenate) {
    call collapse_concatenated_reads.collapse_concatenated_reads {
      input:
        denoise_ch = denoise_ch,
        docker_image = docker_image
    }
  }

  # Use the appropriate denoise input based on just_concatenate
  File denoise_input = select_first([collapse_concatenated_reads.collapsed_reads, denoise_ch])

  # Create reference or use provided one
  if (!defined(refseq_fasta)) {
    call prepare_reference_sequences.prepare_reference_sequences {
      input:
        amplicon_info = amplicon_info,
        docker_string = docker_image
    }
  }

  # Use the appropriate reference
  File reference = select_first([refseq_fasta, prepare_reference_sequences.reference_ch])

  # Align denoised sequences to reference
  call align_to_reference.align_to_reference {
    input:
      denoise_ch = denoise_input,
      reference = reference,
      amplicon_info = amplicon_info,
      docker_image = docker_image
  }

  # Filter ASVs
  call filter_asvs.filter_asvs {
    input:
      alignments = align_to_reference.alignments,
      docker_string = docker_image
  }

  # Set initial alignment table
  File alignment_table = align_to_reference.alignments

  # Mask low complexity regions if needed
  if (!defined(masked_fasta) && (mask_tandem_repeats || mask_homopolymers)) {
    call mask_low_complexity_regions.mask_low_complexity_regions {
      input:
        reference = reference,
        filtered_alignments = filter_asvs.filtered_alignments_ch,
        docker_string = docker_image
    }
    # Update alignment table if masking was done
    alignment_table = mask_low_complexity_regions.masked_alignments
  }

  # Build pseudocigar
  call build_pseudocigar.build_pseudocigar {
    input:
      alignment_table = alignment_table,
      docker_image = docker_image
  }

  output {
    File results_ch = build_pseudocigar.pseudocigar
    File reference_ch = reference
    File aligned_asv_table = alignment_table
  }
}
