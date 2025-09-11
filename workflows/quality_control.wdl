version 1.0

import "../modules/local/preprocess_coverage.wdl" as preprocess_coverage
import "../modules/local/postprocess_coverage.wdl" as postprocess_coverage
import "../modules/local/quality_report.wdl" as quality_report


workflow quality_control {
    input {
        File amplicon_info
        Array[File] sample_coverage_files
        Array[File] amplicon_coverage_files
        File? alleledata
        File? clusters
    }

    call preprocess_coverage.pre_process_coverage {
        input:
            sample_coverages = sample_coverage_files,
            amplicon_coverages = amplicon_coverage_files
    }

    if (defined(alleledata) && defined(clusters)) {
        call postprocess_coverage.post_process_coverage {
            input:
                alleledata = alleledata,
                clusters = clusters,
                sample_coverage = pre_process_coverage.sample_coverage,
                amplicon_coverage = pre_process_coverage.amplicon_coverage
        }
    }

    File final_sample_coverage = select_first([post_process_coverage.postprocess_sample_coverage, pre_process_coverage.sample_coverage])
    File final_amplicon_coverage = select_first([post_process_coverage.postprocess_amplicon_coverage, pre_process_coverage.amplicon_coverage])

    call quality_report.quality_report {
        input:
            sample_coverage = final_sample_coverage,
            amplicon_coverage = final_amplicon_coverage,
            amplicon_info = amplicon_info

    }
}