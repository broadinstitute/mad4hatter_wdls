# Mad4HatterQcOnly

This workflow runs quality control _only_ on the selected samples.

### Inputs: 

| Input Name              | Description                                                           | Type          | Required | Default                       |
|-------------------------|-----------------------------------------------------------------------|---------------|----------|-------------------------------|
| **pools**               | The names of the pools.                                               | Array[String] | Yes      | N/A                           |
| **amplicon_info_files** | The TSVs that contain amplicon information.                           | Array[File]   | Yes      | N/A                           |
| **left_fastqs**         | The "read 1" fastq files.                                             | Array[File]   | Yes      | N/A                           |
| **right_fastqs**        | The "read 2" fastq files.                                             | Array[File]   | Yes      | N/A                           |
| **sequencer**           | The name of the sequencer that was used to process the samples.       | String        | Yes      | N/A                           |
| **cutadapt_minlen**     | The minimum length used for cutadapt. Optional.                       | Int           | No       | 100                           |
| **allowed_errors**      | The number of errors allowed to be encountered in cutadapt. Optional. | Int           | No       | 0                             |
| **docker_image**        | Specifies a custom Docker image to use. Optional.                     | String        | No       | eppicenter/mad4hatter:develop |

### Outputs:

| Output Name               | Type | 
|---------------------------|------|
| **sample_coverage_out**   | File |
| **amplicon_coverage_out** | File |
| **amplicon_stats**        | File |
| **length_vs_reads**       | File |
| **qc_plots_html**         | File |
| **qc_plots_rmd**          | File |
| **reads_histograms**      | File |
| **swarm_plots**           | File |
