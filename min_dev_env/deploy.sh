#!/bin/bash

# Stop and remove the existing container if it exists
docker stop "min-dev-env"
docker rm "min-dev-env"

# Remove the existing image if it exists
docker image rm "min-dev-env"

# Build the Docker image
docker build \
    --build-arg LUA_VERSION="5.4" \
    --build-arg LUAROCKS_VERSION="3.10" \
    --tag "min-dev-env" .

# Run the Docker container
docker run \
    --detach --tty --name "min-dev-env" \
    --hostname "min-dev-env" \
    "min-dev-env"

# bash deploy.sh
