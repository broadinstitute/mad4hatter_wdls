version 1.0

import "modules/local/move_outputs.wdl" as move_outputs

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File final_allele_table
        File sample_coverage_out
        File amplicon_coverage_out
        File dada2_clusters
        File resmarkers_output
        File resmarkers_by_locus
        File microhaps
        File new_mutations
        File amplicon_info_ch
        File reference_fasta
        File resmarkers_file
        String output_cloud_directory
        File amplicon_stats
        File length_vs_reads
        File qc_plots_html
        File qc_plots_rmd
        File reads_histograms
        File swarm_plots
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Testing task
    call move_outputs.move_outputs {
        input:
            output_cloud_directory = output_cloud_directory,
            final_allele_table = final_allele_table,
            sample_coverage_out = sample_coverage_out,
            amplicon_coverage_out = amplicon_coverage_out,
            dada2_clusters = dada2_clusters,
            resmarkers_output = resmarkers_output,
            resmarkers_by_locus = resmarkers_by_locus,
            microhaps = microhaps,
            new_mutations = new_mutations,
            amplicon_info_ch = amplicon_info_ch,
            reference_fasta = reference_fasta,
            resmarkers_file = resmarkers_file,
            amplicon_stats = amplicon_stats,
            length_vs_reads = length_vs_reads,
            qc_plots_html = qc_plots_html,
            qc_plots_rmd = qc_plots_rmd,
            reads_histograms = reads_histograms,
            swarm_plots = swarm_plots
    }

    output {
        File final_allele_table_cloud_path = move_outputs.final_allele_table_cloud_path
        File sample_coverage_cloud_path = move_outputs.sample_coverage_cloud_path
        File amplicon_coverage_cloud_path = move_outputs.amplicon_coverage_cloud_path
        File dada2_clusters_cloud_path = move_outputs.dada2_clusters_cloud_path
        File resmarkers_output_cloud_path = move_outputs.resmarkers_output_cloud_path
        File resmarkers_by_locus_cloud_path = move_outputs.resmarkers_by_locus_cloud_path
        File microhaps_cloud_path = move_outputs.microhaps_cloud_path
        File new_mutations_cloud_path = move_outputs.new_mutations_cloud_path
        File amplicon_info_cloud_path = move_outputs.amplicon_info_cloud_path
        File reference_fasta_cloud_path = move_outputs.reference_fasta_cloud_path
        File resmarkers_file_cloud_path = move_outputs.resmarkers_file_cloud_path
        File amplicon_stats_cloud_path = move_outputs.amplicon_stats_cloud_path
        File length_vs_reads_cloud_path = move_outputs.length_vs_reads_cloud_path
        File qc_plots_html_cloud_path = move_outputs.qc_plots_html_cloud_path
        File qc_plots_rmd_cloud_path = move_outputs.qc_plots_rmd_cloud_path
        File reads_histograms_cloud_path = move_outputs.reads_histograms_cloud_path
        File swarm_plots_cloud_path = move_outputs.swarm_plots_cloud_path
    }
}