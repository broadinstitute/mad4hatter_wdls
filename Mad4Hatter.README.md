# MAD4HatTeR Pipeline - WDL Implementation

## Overview

MAD4HatTeR (Malaria Amplicon Deep-sequencing for Haplotype and Target Resistance) is a comprehensive pipeline for processing malaria amplicon sequencing data. This WDL implementation processes raw sequencing reads through demultiplexing, denoising, quality control, and resistance marker analysis.

## Usage

The typical command for running the pipeline is as follows:
```bash
# Example using Cromwell
java -jar cromwell.jar run main.wdl --inputs inputs.json
```

## Workflow Modes

The pipeline supports three main workflow modes:

### 1. Complete Pipeline (default)
Runs the full pipeline from raw reads to final results including:
- Demultiplexing amplicons by target region
- DADA2 denoising and ASV inference
- Sequence masking and collapsing
- Allele table generation
- Quality control reporting
- Resistance marker analysis

### 2. QC Only
Runs quality control analysis only - useful for initial data assessment.

### 3. Post-processing Only
Runs post-processing from pre-existing denoised ASVs.

## Input Parameters

### Mandatory Arguments

| Parameter | Type | Description |
|-----------|------|-------------|
| `pools` | String | The pools that were used for sequencing. Options: D1, R1, R2, D1.1, R1.1, R1.2, R2.1, 4cast, ama1, v1, v2, 1A, 1B, 2, 5 |
| `sequencer` | String | The sequencer used to produce your data. Options: miseq, nextseq |

### Workflow-Specific Mandatory Arguments

| Parameter | Type | Required For | Description |
|-----------|------|--------------|-------------|
| `read_pairs` | Array[Pair[File, File]] | complete, qc | Array of paired FASTQ files (R1, R2) |
| `denoised_asvs` | File | postprocessing | Path to denoised ASVs from DADA2 |

### Optional Arguments

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `workflow_type` | String | "complete" | Workflow option to be run. Options: complete, qc, postprocessing |
| `amplicon_info` | File | auto-generated | Pre-existing amplicon info file |
| `docker_image` | String | "mad4hatter:latest" | Docker image to use for all tasks |

### DADA2 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `omega_a` | Float | 1E-120 | Level of statistical evidence required for DADA2 to infer a new ASV |
| `dada2_pool` | String | "pseudo" | Pooling method for DADA2. Options: pseudo, true, false |
| `band_size` | Int | 16 | Limit on the net cumulative number of insertions of one sequence relative to the other |
| `maxEE` | Int | 3 | Limit on number of expected errors within a read during filtering and trimming |

### Post-processing Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `concat_non_overlaps` | Boolean | false | Whether to concatenate or discard sequences that DADA2 was unable to merge |
| `refseq_fasta` | File | auto-generated | Path to targeted reference sequences |
| `genome` | File | optional | Path to full genome covering all targets |
| `homopolymer_threshold` | Int | 5 | The length a homopolymer must reach to be masked |
| `trf_min_score` | Int | 25 | The alignment score threshold for tandem repeat masking |
| `trf_max_period` | Int | 3 | The maximum pattern size for tandem repeat masking |

### Resistance Marker Module Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `resmarker_info` | File | auto-generated | Path to table of resistance marker info |

## Example Input JSON Files

### Complete Workflow Example
```json
{
  "MAD4HatTeR.pools": "D1,R1,R2",
  "MAD4HatTeR.sequencer": "nextseq",
  "MAD4HatTeR.read_pairs": [
    {"left": "sample1_R1.fastq.gz", "right": "sample1_R2.fastq.gz"},
    {"left": "sample2_R1.fastq.gz", "right": "sample2_R2.fastq.gz"}
  ],
  "MAD4HatTeR.workflow_type": "complete"
}
```

### QC Only Example
```json
{
  "MAD4HatTeR.pools": "D1,R1",
  "MAD4HatTeR.sequencer": "miseq",
  "MAD4HatTeR.read_pairs": [
    {"left": "sample1_R1.fastq.gz", "right": "sample1_R2.fastq.gz"}
  ],
  "MAD4HatTeR.workflow_type": "qc"
}
```

### Post-processing Only Example
```json
{
  "MAD4HatTeR.pools": "D1,R1,R2",
  "MAD4HatTeR.sequencer": "nextseq",
  "MAD4HatTeR.denoised_asvs": "results/raw_dada2_output/dada2.clusters.txt",
  "MAD4HatTeR.workflow_type": "postprocessing"
}
```

### Advanced Usage with Custom Parameters
```json
{
  "MAD4HatTeR.pools": "D1,R1,R2",
  "MAD4HatTeR.sequencer": "nextseq",
  "MAD4HatTeR.read_pairs": [
    {"left": "sample1_R1.fastq.gz", "right": "sample1_R2.fastq.gz"}
  ],
  "MAD4HatTeR.workflow_type": "complete",
  "MAD4HatTeR.omega_a": 1E-40,
  "MAD4HatTeR.dada2_pool": "false",
  "MAD4HatTeR.band_size": 20,
  "MAD4HatTeR.maxEE": 4,
  "MAD4HatTeR.concat_non_overlaps": true,
  "MAD4HatTeR.homopolymer_threshold": 2,
  "MAD4HatTeR.trf_min_score": 30,
  "MAD4HatTeR.trf_max_period": 5,
  "MAD4HatTeR.docker_image": "custom_mad4hatter:v1.0"
}
```

## Pipeline Steps (Complete Workflow)

1. **Input Validation**: Ensures all required parameters are present and valid
2. **Amplicon Info Generation**: Creates amplicon information table based on specified pools
3. **Demultiplexing**: Separates reads by amplicon target and performs initial quality filtering
4. **First Denoising**: DADA2 error correction, dereplication, and initial ASV inference
5. **Second Denoising**: Sequence masking, ASV collapsing, and final ASV table creation
6. **Allele Table Building**: Creates comprehensive allele frequency table
7. **Quality Control**: Generates QC metrics and visualizations
8. **Resistance Analysis**: Identifies and analyzes known resistance markers

## Output Files

### Complete Workflow Outputs
- `final_allele_table`: Comprehensive allele frequency table
- `resistance_analysis`: Resistance marker analysis results
- `sample_summary`: Per-sample processing summary
- `amplicon_summary`: Per-amplicon processing summary

### QC Workflow Outputs
- `qc_report`: Quality control analysis report

### Post-processing Workflow Outputs
- `postproc_results`: Final post-processing results

## Pool Options

The pipeline supports the following pool configurations:

- **Default pools**: D1, R1, R2
- **Full versioned pools**: D1.1, R1.1, R1.2, R2.1
- **Legacy pool names**: 1A, 1B, 2, 5
- **Specialized panels**: 4cast, ama1, v1, v2

Each pool corresponds to specific amplicon panels with associated reference sequences and amplicon information.

## Requirements

- WDL-compatible execution engine (Cromwell, Terra, etc.)
- Docker runtime
- Sufficient computational resources for DADA2 processing
- Input FASTQ files in standard Illumina format

## Support

For questions or issues with the MAD4HatTeR pipeline, please contact the development team or refer to the project documentation.
