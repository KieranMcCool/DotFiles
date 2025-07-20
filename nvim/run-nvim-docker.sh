#!/bin/bash

IMAGE_NAME="my-nvim"

# Build the Docker image

docker build -t $IMAGE_NAME .

# Run the container interactively, mounting the current directory

docker run --rm -it -v "$PWD":/workspace -w /workspace $IMAGE_NAME
