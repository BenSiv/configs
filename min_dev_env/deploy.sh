#!/bin/bash

# Stop and remove the existing container if it exists
podman stop "min-dev-env"
podman rm "min-dev-env"

# Remove the existing image if it exists
podman image rm "min-dev-env"

# Build the podman image
podman build \
    --build-arg LUA_VERSION="5.1" \
    --build-arg LUAROCKS_VERSION="3.10" \
    --tag "min-dev-env" .

# Run the podman container
podman run \
    --detach --tty --name "min-dev-env" \
    --hostname "min-dev-env" \
    "min-dev-env"

# bash deploy.sh
