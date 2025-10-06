version 1.0

import "../modules/local/preprocess_coverage.wdl" as preprocess_coverage
import "../modules/local/postprocess_coverage.wdl" as postprocess_coverage
import "../modules/local/quality_report.wdl" as quality_report


workflow quality_control {
    input {
        File amplicon_info_ch
        Array[File] sample_coverage_files
        Array[File] amplicon_coverage_files
        File? alleledata
        File? clusters
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    # Initial Preprocessing
    call preprocess_coverage.preprocess_coverage {
        input:
            sample_coverages = sample_coverage_files,
            amplicon_coverages = amplicon_coverage_files,
            docker_image = docker_image
    }

    # If postprocessing coverage is provided, run the postprocessing workflow
    if (defined(alleledata) && defined(clusters)) {
        File defined_alleledata = select_first([alleledata])
        File defined_clusters = select_first([clusters])

        call postprocess_coverage.postprocess_coverage {
            input:
                alleledata = defined_alleledata,
                clusters = defined_clusters,
                sample_coverage = preprocess_coverage.sample_coverage,
                amplicon_coverage = preprocess_coverage.amplicon_coverage
        }
    }

    File final_sample_coverage = select_first([postprocess_coverage.postprocess_sample_coverage, preprocess_coverage.sample_coverage])
    File final_amplicon_coverage = select_first([postprocess_coverage.postprocess_amplicon_coverage, preprocess_coverage.amplicon_coverage])

    call quality_report.quality_report {
        input:
            sample_coverage = final_sample_coverage,
            amplicon_coverage = final_amplicon_coverage,
            amplicon_info_ch = amplicon_info_ch

    }

    output {
        File sample_coverage_out = quality_report.sample_coverage_out
        File amplicon_coverage_out = quality_report.amplicon_coverage_out
        File amplicon_stats = quality_report.amplicon_stats
        File length_vs_reads = quality_report.length_vs_reads
        File qc_plots_html = quality_report.qc_plots_html
        File qc_plots_rmd = quality_report.qc_plots_rmd
        File reads_histograms = quality_report.reads_histograms
        File swarm_plots = quality_report.swarm_plots
    }
}