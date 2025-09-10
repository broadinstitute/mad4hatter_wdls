version 1.0

# This workflow allows users to optionally create a reference from genomes or use a default
import "../modules/local/create_reference_from_genomes.wdl" as create_reference_from_genomes
import "../workflows/process_inputs.wdl" as process_inputs

workflow prepare_reference_sequences {
  input {
    File amplicon_info
    File? genome

    # Defaults from the original Nextflow script
    # The WDL engine handles these boolean checks
    Boolean mask_tandem_repeats = true
    Int trf_min_score = 25
    Int trf_max_period = 3
    Boolean mask_homopolymers = true
    Int homopolymer_threshold = 5

    String docker_image = ""
  }

  if (defined(genome)) {
    call create_reference_from_genomes.create_reference_from_genomes {
      input:
        genome = genome,
        amplicon_info = amplicon_info,
        refseq_fasta = "reference.fasta",
        docker_name = docker_image,
    }
  }
  # TODO concatenate_targeted_reference in process_inputs.wdl is not converted to WDL yet and currently doesn't
  # take an inputs. This may have to be updated if that changes at all
  if (!defined(genome)) {
    call process_inputs.concatenate_targeted_reference {
    }
  }

  output {
    File reference_fasta = select_first([
      concatenate_targeted_reference.reference_fasta,
      create_reference_from_genomes.reference_fasta
    ])
  }
}