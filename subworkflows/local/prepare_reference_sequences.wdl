version 1.0

# This workflow allows users to optionally create a reference from genomes or use a default
import "../../modules/local/create_reference_from_genomes.wdl" as create_reference_from_genomes
import "../../workflows/process_inputs.wdl" as process_inputs
import "../../modules/local/error_with_message.wdl" as error_with_message

workflow prepare_reference_sequences {
  input {
    File amplicon_info
    File? genome
    Array[File]? reference_input_paths
    Boolean mask_tandem_repeats = true
    Int trf_min_score = 25
    Int trf_max_period = 3
    Boolean mask_homopolymers = true
    Int homopolymer_threshold = 5
    String docker_image = "eppicenter/mad4hatter:dev"
  }

  # Case 1: both provided → fail
  if (defined(genome) && defined(reference_input_paths)) {
    call error_with_message.ErrorWithMessage {
      input:
      message = "Error: Cannot accept both 'genome' and 'reference_input_paths'. Please provide only one."
    }
  }

  # Case 2: neither provided → fail
  if (!defined(genome) && !defined(reference_input_paths)) {
    call error_with_message.ErrorWithMessage {
      input:
        message = "Error: You must provide either 'genome' OR 'reference_input_paths'."
    }
  }

  # TODO: Test out this path after create_reference_from_genomes inputs are provided
  if (defined(genome)) {
    call create_reference_from_genomes.create_reference_from_genomes {
      input:
        genome = genome,
        amplicon_info = amplicon_info,
        refseq_fasta = "reference.fasta",
        docker_image = docker_image,
    }
  }

  if (!defined(genome)) {
    Array[File] defined_paths = select_first([reference_input_paths])
    call process_inputs.concatenate_targeted_reference {
      input:
        reference_input_paths = defined_paths,
        docker_image = docker_image
    }
  }

  output {
    File reference_fasta = select_first([
      concatenate_targeted_reference.reference_fasta,
      create_reference_from_genomes.reference_fasta
    ])
  }
}