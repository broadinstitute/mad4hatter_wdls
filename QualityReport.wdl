version 1.0

workflow QualityReport {

    meta {
        description: "Generate a quality control report for the amplicon sequencing data."
    }

    parameter_meta {
        amplicon_coverage: "Mad4Hatter amplicon coverage file."
        sample_coverage: "Mad4Hatter sample coverage file."
        amplicon_info: "Mad4Hatter amplicon info file."
        docker_image: "Docker image to use to create the quality control report."
    }

    input {
        File amplicon_coverage
        File sample_coverage
        File amplicon_info

        String docker_image = "us.gcr.io/broad-dsp-lrma/sr-mad4hatter:0.0.1"
    }

    call create_quality_report as t_01_create_quality_report {
        input:
            amplicon_coverage = amplicon_coverage,
            sample_coverage = sample_coverage,
            amplicon_info = amplicon_info,
            docker_image = docker_image
    }

    output {
        File qc_amplicon_stats = t_01_create_quality_report.amplicon_stats
        File qc_length_vs_reads = t_01_create_quality_report.length_vs_reads
        File qc_plots_html = t_01_create_quality_report.qcplots_html
        File qc_plots_Rmd = t_01_create_quality_report.qcplots_Rmd
        File qc_reads_histograms = t_01_create_quality_report.reads_histograms
        File qc_swarm_plots = t_01_create_quality_report.swarm_plots
        
        File quality_report_tar_gz = t_01_create_quality_report.quality_report_tar_gz
    }
}

task create_quality_report {

    meta {
        description: "Create a set of quality control outputs for the amplicon sequencing data."
    }

    parameter_meta {
       qc_r_script: "R script to use to create the quality control outputs."
       docker_image: "Docker image to use to create the quality control outputs."
       amplicon_coverage: "Mad4Hatter amplicon coverage file."
       sample_coverage: "Mad4Hatter sample coverage file."
       amplicon_info: "Mad4Hatter amplicon info file."
    }

    input {
        File amplicon_coverage
        File sample_coverage
        File amplicon_info

        File qc_r_script = "gs://fc-a51e78f3-024d-415f-848e-aa7046173b53/scripts/cutadapt_summaryplots.R"
        String docker_image = "us.gcr.io/broad-dsp-lrma/sr-mad4hatter:0.0.1"
    }

    String quality_report_dir_name = "quality_report"

    command <<<
        set -euxo pipefail

        mkdir -p ~{quality_report_dir_name}
        Rscript ~{qc_r_script} ~{amplicon_coverage} ~{sample_coverage} ~{amplicon_info} ~{quality_report_dir_name}

        tar -zcf ~{quality_report_dir_name}.tar.gz ~{quality_report_dir_name}

        # Note:  The following files should be present in the ~{quality_report_dir_name} directory:
        # ~{quality_report_dir_name}/amplicon_stats.txt
        # ~{quality_report_dir_name}/length_vs_reads.pdf
        # ~{quality_report_dir_name}/QCplots.html
        # ~{quality_report_dir_name}/QCplots.Rmd
        # ~{quality_report_dir_name}/reads_histograms.pdf
        # ~{quality_report_dir_name}/swarm_plots.pdf
    >>>

    output {
        File amplicon_stats = "~{quality_report_dir_name}/amplicon_stats.txt"
        File length_vs_reads = "~{quality_report_dir_name}/length_vs_reads.pdf"
        File qcplots_html = "~{quality_report_dir_name}/QCplots.html"
        File qcplots_Rmd = "~{quality_report_dir_name}/QCplots.Rmd"
        File reads_histograms = "~{quality_report_dir_name}/reads_histograms.pdf"
        File swarm_plots = "~{quality_report_dir_name}/swarm_plots.pdf"

        File quality_report_tar_gz = "~{quality_report_dir_name}.tar.gz"
    }

    runtime {
        docker: docker_image
    }





}

