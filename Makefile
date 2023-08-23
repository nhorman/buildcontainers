.PHONY: %-container 

%: 
	@echo building $@ container
	podman build -t $@-container ${PODMAN_BUILD_ARGS} --build-arg-file=./container_configs/$@.env --build-arg-file=./versions.env -f Dockerfile.builder

%-clean:
	podman rmi -f $@-container


list-available:
	@echo Available container builds
	@/bin/bash -c "ls container_configs/*.env | sed -e\"s/container_configs\///\" -e\"s/\.env//\""
