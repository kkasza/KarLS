# KarLS Builder for Docker
Docker container for building KarLS from source

This dockerfile is for building your own KarLS image simply in a Docker container.
The container is based on Debian Bookworm.

To build, download the dockerfile into an empty directory (no need to mirror the whole git), and run:
> docker build -t karls-builder .

> [!NOTE]
> This will run for a long time, I recommend running it inside a detachable terminal, like *tmux*. It will require around 16 GB.

Then to get the iso if built succesfully, first create a container instance from the image:
> docker create --name karls-tmp karls-builder 

Copy the iso from the container:
> docker cp karls-tmp:/karls/iso/karls-1.0-x86_64.iso ./karls-1.0-x86_64.iso 

And remove the container instance:
> docker rm karls-tmp

To completely delete the build image, run:
> docker rmi `docker images -aq -f label=karls=builder`
