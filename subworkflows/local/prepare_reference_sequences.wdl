version 1.0

# This workflow allows users to optionally create a reference from genomes or use a default
import "../../modules/local/create_reference_from_genomes.wdl" as create_reference_from_genomes
import "../../workflows/process_inputs.wdl" as process_inputs
import "../../modules/local/error_with_message.wdl" as error_with_message

workflow prepare_reference_sequences {
  input {
    File? amplicon_info_ch
    File? genome
    Array[File]? reference_input_paths
    Boolean mask_tandem_repeats = true
    Int trf_min_score = 25
    Int trf_max_period = 3
    Boolean mask_homopolymers = true
    Int homopolymer_threshold = 5
    String docker_image = "eppicenter/mad4hatter:develop"
  }

  Boolean invalid = (defined(genome) && defined(reference_input_paths)) || (!defined(genome) && !defined(reference_input_paths))
  Boolean invalid_amplicon = defined(genome) && !defined(amplicon_info_ch)

  if (invalid) {
    call error_with_message.error_with_message {
      input:
        message = "Error: Exactly one of 'genome' or 'reference_input_paths' must be provided."
    }
  }

  if (invalid_amplicon) {
      call error_with_message.error_with_message as ErrorMessageInvalidAmplicon {
      input:
          message = "Error: 'amplicon_info' must be provided when 'genome' is provided."
      }
  }

  if (defined(genome)) {
    File defined_genome_path = select_first([genome])
    File defined_amplicon_info = select_first([amplicon_info_ch])

    call create_reference_from_genomes.create_reference_from_genomes {
      input:
        genome = defined_genome_path,
        amplicon_info_ch = defined_amplicon_info,
        docker_image = docker_image,
    }
  }

  if (!defined(genome)) {
    Array[File] defined_reference_input_paths = select_first([reference_input_paths])
    call process_inputs.concatenate_targeted_reference {
      input:
        reference_input_paths = defined_reference_input_paths,
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