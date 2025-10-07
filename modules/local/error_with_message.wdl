version 1.0

# Print given message to stderr and return an error
task error_with_message {
    input {
        String message
    }

    command <<<
        >&2 echo "Error: ~{message}"
        exit 1
    >>>

    runtime {
        docker: "ubuntu:20.04"
    }
}