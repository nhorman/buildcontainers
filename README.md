# buildcontainers
my attempt to create a single cross-compliation container dockerfile
## Usage
to list the available cross compilation configurations:
make list-available
to build a cross build container:
make <target>
where <target is one of the items returned by make list-available
## Configuration
the files in container_configs list the settings for each target container
the version.env file lists the versions of the cross tool components to build
## Availability
prebuilt containers are available on docker hub at:
https://hub.docker.com/repository/docker/nhorman/builders/general
