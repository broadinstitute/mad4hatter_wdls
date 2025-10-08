version 1.0

import "workflows/process_inputs.wdl" as ProcessInputs
import "workflows/postproc_only.wdl" as PostProc

workflow Mad4HatterPostProcessing {
    input {
        Array[String] pools
        Array[File] amplicon_info_files
        File clusters
        Boolean just_concatenate = true
        Boolean mask_tandem_repeats = true
        Boolean mask_homopolymers = true
        File? genome
        File? refseq_fasta
        File? masked_fasta
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    call ProcessInputs.generate_amplicon_info {
        input:
            pools = pools,
            docker_image = docker_image,
            amplicon_info_files = amplicon_info_files
    }

    call PostProc.postproc_only {
        input:
            amplicon_info_ch = generate_amplicon_info.amplicon_info_ch,
            clusters = clusters,
            just_concatenate = just_concatenate,
            mask_tandem_repeats = mask_tandem_repeats,
            mask_homopolymers = mask_homopolymers,
            genome = genome,
            refseq_fasta = refseq_fasta,
            masked_fasta = masked_fasta,
            docker_image = docker_image
    }

    output {
        File reference_ch = postproc_only.reference_ch
        File aligned_asv_table = postproc_only.aligned_asv_table
        File alleledata = postproc_only.alleledata
    }
}