#!/bin/bash

# Stop and remove the existing container if it exists
docker stop minimal-dev
docker rm minimal-dev

# Remove the existing image if it exists
docker image rm minimal-dev

# Build the Docker image
docker build \
    --build-arg LUA_VERSION="5.1" \
    --build-arg LUAROCKS_VERSION="3.10.0" \
    --tag minimal-dev .

# Run the Docker container
docker run \
    --detach --tty --name "minimal-dev" \
    --hostname "minimal-dev" \
    "minimal-dev"

# bash deploy.sh
