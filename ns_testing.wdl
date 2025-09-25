version 1.0

import "workflows/quality_control.wdl" as QualityControl

# Can be used for testing subworkflows and modules
workflow QualityControlTest {
    input {
        File amplicon_info
        Array[File] sample_coverage_files
        Array[File] amplicon_coverage_files
        File? alleledata
        File? clusters
    }

    # Testing task
    call QualityControl.quality_control {
        input:
            amplicon_info = amplicon_info,
            sample_coverage_files = sample_coverage_files,
            amplicon_coverage_files = amplicon_coverage_files,
            alleledata = alleledata,
            clusters = clusters
    }

    output {
        File sample_coverage_out = quality_control.sample_coverage_out
        File amplicon_coverage_out = quality_control.amplicon_coverage_out
        Array[File] quality_reports = quality_control.quality_reports
    }
}