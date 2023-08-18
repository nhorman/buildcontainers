.PHONY: all check clean

check:
	@if [ -z "${CNAME}" ]; then echo "Need to set CNAME"; exit 1; fi

all: check
	podman build -t ${CNAME} --squash -f Dockerfile.builder

clean: check
	podman rmi localhost/${CNAME}
