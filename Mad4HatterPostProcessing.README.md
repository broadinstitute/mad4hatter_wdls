# Mad4HatterPostProcessing

This workflow runs postprocessing _only_.

### Inputs:

| Input Name              | Description                                            | Type          | Required | Default                       |
|-------------------------|--------------------------------------------------------|---------------|----------|-------------------------------|
| **pools**               | The names of the pools.                                | Array[String] | Yes      | N/A                           |
| **amplicon_info_files** | The TSVs that contain amplicon information.            | Array[File]   | Yes      | N/A                           |
| **clusters**            | The clusters file.                                     | File          | Yes      | N/A                           |
| **just_concatenate**    | Whether non-overlaps should be concatenated. Optional. | Boolean       | No       | true                          |
| **mask_tandem_repeats** | Whether tandem repeats should be masked. Optional.     | Boolean       | No       | true                          |
| **mask_homopolymers**   | Whether homopolymers should be masked. Optional.       | Boolean       | No       | true                          |
| **refseq_fasta**        | The reference fasta file.                              | File          | Yes      | N/A                           |
| **masked_fasta**        | The masked fasta file.                                 | File          | No       | N/A                           |
| **docker_image**        | Specifies a custom Docker image to use. Optional.      | String        | No       | eppicenter/mad4hatter:develop |


### Outputs:


| Output Name           | Type | 
|-----------------------|------|
| **reference_ch**      | File |
| **aligned_asv_table** | File |
| **alleledata**        | File |
