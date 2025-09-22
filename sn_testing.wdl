version 1.0

import "modules/local/quality_report.wdl" as quality_report

# Can be used for testing subworkflows and modules
workflow TestWdl {
    input {
        File sample_coverage
        File amplicon_coverage
        File amplicon_info
        String docker_image = "eppicenter/mad4hatter:dev"
    }

    # Testing task
    call quality_report.quality_report as quality_report {
        input:
            sample_coverage = sample_coverage,
            amplicon_coverage = amplicon_coverage,
            amplicon_info = amplicon_info,
            docker_image = docker_image
    }

    output {
        File sample_coverage_out = quality_report.sample_coverage_out
        File amplicon_coverage_out = quality_report.amplicon_coverage_out
        Directory quality_report = quality_report.quality_report
    }
}