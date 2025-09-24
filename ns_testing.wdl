version 1.0

import "subworkflows/local/mask_low_complexity_regions.wdl" as mask_low_complexity_regions

# Can be used for testing subworkflows and modules
workflow MaskLowComplexityRegionsTesting {
    input {
        File reference
        File alignments
    }

    call mask_low_complexity_regions.mask_low_complexity_regions {
        input:
            reference = reference,
            alignments = alignments
    }

    output {
<<<<<<< Updated upstream
        File sample_summary = cutadapt.sample_summary
        File amplicon_summary = cutadapt.amplicon_summary
        Array[File] demultiplexed_fastqs = cutadapt.demultiplexed_fastqs
=======
        File masked_alignments = mask_low_complexity_regions.masked_alignments
>>>>>>> Stashed changes
    }
}