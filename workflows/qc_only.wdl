version 1.0

import "../demultiplex_amplicons.wdl" as demultiplex_amplicons
import "../quality_control.wdl" as quality_control

# This workflow is meant to drive quality control of amplicon sequencing data
workflow qc_only {
    input {
        File amplicon_info
        File reads
    }

    call demultiplex_amplicons.demultiplex_amplicons {
        input:
            amplicon_info = amplicon_info,
            # TODO figure out what read_pairs should be here
            read_pairs = "",
            # TODO fill in docker name when avaiable
            docker_name = ""
    }

    call quality_control.quality_control {
        input:
            amplicon_info = amplicon_info,
            sample_coverage_files = demultiplex_amplicons.sample_summary_ch,
            amplicon_coverage_files = demultiplex_amplicons.amplicon_summary_ch
    }

}

