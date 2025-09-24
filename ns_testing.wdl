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
        File masked_alignments = mask_low_complexity_regions.masked_alignments
    }
}