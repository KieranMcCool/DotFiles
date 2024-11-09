#!/bin/bash

# Set the name of the Docker image
imageName="kieran-env"

# Get the path to the current user's Documents folder
documentsPath="$HOME/Documents"
devPlaygroundPath="$documentsPath/dev-playground"
sharedPath="$devPlaygroundPath/shared"

# Create a unique instance ID
instanceId=$(uuidgen)
instancePath="$devPlaygroundPath/$instanceId"

# Ensure the shared directory exists
if [ ! -d "$sharedPath" ]; then
    echo "Creating shared folder at $sharedPath"
    mkdir -p "$sharedPath"
else
    echo "Shared folder already exists at $sharedPath"
fi

# Create the unique instance folder
echo "Creating instance folder at $instancePath"
mkdir -p "$instancePath"

# Detect changes and rebuild the image if necessary
# Set the current directory as the path to the Dockerfile
dockerfilePath=$(pwd)
latestImageId=$(docker images -q "$imageName")
buildRequired=false

if [ -z "$latestImageId" ]; then
    echo "No existing image found. Building image $imageName."
    buildRequired=true
else
    # Check if there are uncommitted changes or differences since the last build
    changedFiles=$(git -C "$dockerfilePath" diff --name-only HEAD)
    if [ -n "$changedFiles" ]; then
        echo "Changes detected in the repository. Rebuilding the Docker image."
        buildRequired=true
    fi
fi

# Rebuild the image if necessary
if [ "$buildRequired" = true ]; then
    docker build -t "$imageName" "$dockerfilePath"
else
    echo "No changes detected. Using the existing image $imageName."
fi

# Run Docker container with the shared and instance-specific volumes
echo "Starting Docker container with shared and instance-specific volumes mounted"
docker run -it --rm \
    -v "${sharedPath}:/workspace/shared" \
    -v "${instancePath}:/workspace/instance" \
    --network=host \
    "$imageName" bash
