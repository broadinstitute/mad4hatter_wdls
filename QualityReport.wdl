version 1.0

workflow quality_report {

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

        String docker_image = "eppicenter/mad4hatter:develop"
    }

    call create_quality_report as t_01_create_quality_report {
        input:
            amplicon_coverage = amplicon_coverage,
            sample_coverage = sample_coverage,
            amplicon_info = amplicon_info,
            docker_image = docker_image
    }

    output {
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
        String docker_image = "eppicenter/mad4hatter:develop"
    }

    String quality_report_dir_name = "quality_report"

    command <<<
        set -euxo pipefail

        Rscript ~{basename(qc_r_script)} ~{amplicon_coverage} ~{sample_coverage} ~{amplicon_info} ~{quality_report_dir_name}

        tar -zcf ~{quality_report_dir_name}.tar.gz ~{quality_report_dir_name}
    >>>

    output {
        File quality_report_tar_gz = "~{quality_report_dir_name}.tar.gz"
    }

    runtime {
        docker: docker_image
    }





}

