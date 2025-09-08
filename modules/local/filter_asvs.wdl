version 1.0

# Prepare the primer files from the given amplicon_info file
task FilterASVs {
  input {
    File alignments
  }

  # Pulled default value from https://github.com/EPPIcenter/mad4hatter/blob/0fdf688d8bef6b1407de66ed2644a2d26635015d/nextflow.config#L32
  Int alignment_threshold = 60
  # TODO: Fill in docker image here when available
  String docker_image = ""

  command <<<
  set -euo pipefail

  bash /bin/filter_asv_process.sh \
    -i ~{alignments} \
    -o filtered.alignments.txt \
    -t ~{alignment_threshold}
  >>>

  output {
    File filtered_alignments_ch = "filtered.alignments.txt"
  }

  runtime {
    docker: "~{docker_image}"
    cpu: 1
    memory: "8G"
  }
}