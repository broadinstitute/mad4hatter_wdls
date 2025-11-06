version 1.0

# Print given message to stderr and return an error
task get_amplicon_and_targeted_ref_from_config {
    input {
        Array[String] pools
        String docker_image = "eppicenter/mad4hatter:develop"
        String config_file_path = "/opt/config/wdl.config" # located on docker
    }

    command <<<
        python3 <<CODE
        import json

        with open(~{config_file_path}) as f:
            pool_config = json.load(f)

        amplicon_info_paths = []
        targeted_reference_paths = []
        missing_pools = []
        available_pools_dict = pool_config['params']['pool_options']

        #TODO: Is this how you access list in python from WDL?
        for pool in "~{pools}".split(" "):
            if pool in available_pools_dict:
                amplicon_info_paths.append(available_pools_dict[pool]["amplicon_info_path"])
                targeted_reference_paths.append(available_pools_dict[pool]["targeted_reference_path"])
            else:
                missing_pools.append(pool)
        if missing_pools:
            raise ValueError(f"The following pools are not available in the config: {', '.join(missing_pools)}")

        # Write the paths to output files
        with open("amplicon_info_paths.txt", "w") as f:
        for path in amplicon_info_paths:
            f.write(path + "\n")

        with open("targeted_reference_paths.txt", "w") as f:
            for path in targeted_reference_paths:
                f.write(path + "\n")
        CODE
    >>>

    output {
        Array[File] amplicon_info_files = read_lines("amplicon_info_paths.txt")
        Array[File] targeted_reference_files = read_lines("targeted_reference_paths.txt")
    }

    runtime {
        docker: docker_image
    }
}