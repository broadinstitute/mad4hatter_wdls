version 1.0

import "../modules/local/align_to_reference.wdl" as align_to_reference
import "../subworkflows/local/mask_low_complexity_regions.wdl" as mask_low_complexity_regions
import "../subworkflows/local/prepare_reference_sequences.wdl" as prepare_reference_sequences
import "../modules/local/build_pseudocigar.wdl" as build_pseudocigar
import "../modules/local/filter_asvs.wdl" as filter_asvs
import "../modules/local/collapse_concatenated_reads.wdl" as collapse_concatenated_reads

workflow denoise_amplicons_2 {
  input {
    File amplicon_info_ch
    File clusters
    Boolean just_concatenate
    File? refseq_fasta
    File? masked_fasta
    Boolean mask_tandem_repeats
    Boolean mask_homopolymers
    String docker_image = "eppicenter/mad4hatter:develop"
  }

  # Process clusters if just_concatenate is true
  if (just_concatenate) {
    call collapse_concatenated_reads.collapse_concatenated_reads {
      input:
        clusters = clusters,
        docker_image = docker_image
    }
  }

  # Use the appropriate denoise input based on just_concatenate
  File denoise_input = select_first([collapse_concatenated_reads.clusters_concatenated_collapsed, clusters])

  # Create reference or use provided one
  if (!defined(refseq_fasta)) {
    call prepare_reference_sequences.prepare_reference_sequences {
      input:
        amplicon_info_ch = amplicon_info_ch,
        docker_image = docker_image
    }
  }

  # Use the appropriate reference
  File reference = select_first([prepare_reference_sequences.reference_fasta, refseq_fasta])

  # Align denoised sequences to reference
  call align_to_reference.align_to_reference {
    input:
      clusters = denoise_input,
      refseq_fasta = reference,
      amplicon_info_ch = amplicon_info_ch,
      docker_image = docker_image
  }

  # Filter ASVs
  call filter_asvs.filter_asvs {
    input:
      alignments = align_to_reference.alignments,
      docker_image = docker_image
  }

  # Mask low complexity regions if needed
  if (!defined(masked_fasta) && (mask_tandem_repeats || mask_homopolymers)) {
    call mask_low_complexity_regions.mask_low_complexity_regions {
      input:
        reference = reference,
        alignments = filter_asvs.filtered_alignments_ch,
        docker_image = docker_image
    }
  }

  # Set initial alignment table. Update if masked_fasta is provided
  File alignment_table = select_first([mask_low_complexity_regions.masked_alignments, align_to_reference.alignments])

  # Build pseudocigar
  call build_pseudocigar.build_pseudocigar {
    input:
      alignments = alignment_table,
      docker_image = docker_image
  }

  output {
    File results_ch = build_pseudocigar.pseudocigar
    File reference_ch = reference
    File aligned_asv_table = alignment_table
  }
}
