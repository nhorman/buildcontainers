.PHONY: %-container 

%: 
	@echo building $@ container
	podman build -t $@-container --squash --env-file=./container_configs/$@.env --env-file=./versions.env -f Dockerfile.builder

%-clean:
	podman rmi -f $@-container


list-available:
	@echo Available container builds
	@/bin/bash -c "ls container_configs/*.env | sed -e\"s/container_configs\///\" -e\"s/\.env//\""
