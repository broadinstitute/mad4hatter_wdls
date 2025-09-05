#TODO: Convert to WDL

process MASK_REFERENCE_HOMOPOLYMERS {

  label 'process_medium'
  conda 'envs/postproc-env.yml'

  input:
  path refseq_fasta
  val homopolymer_threshold

  output:
  path "*.mask", emit: masked_fasta

  script:
  """
  Rscript ${projectDir}/bin/mask_homopolymers.R \
    --refseq-fasta ${refseq_fasta} \
    --homopolymer_threshold ${homopolymer_threshold}

  """
}