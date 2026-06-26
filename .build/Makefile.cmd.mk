
cmd-exec: lastpass-login hashivault-login
	@ export DOCKER_FLAGS="-i"; \
    $(docker-exec) /bin/bash -i -c "\
        export PATH=$(BUILD_FRAMEWORK_DIR)/.ssh:\$$PATH && \
        ssh \
            -T \
            -o RequestTTY=no \
			-o ControlMaster=auto \
			-o ControlPersist=10m \
			-o ControlPath=/tmp/ssh_mux_%h_%p_%r \
            -F $(BUILD_FRAMEWORK_DIR)/.ssh/ssh_config \
            $(USERNAME)@$(LIMIT) \
            '$(CMD)' \
    "
