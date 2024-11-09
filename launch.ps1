# Set the name of the Docker image
$imageName = "kieran-env"

# Get the path to the current user's Documents folder
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$devPlaygroundPath = Join-Path -Path $documentsPath -ChildPath "dev-playground"
$sharedPath = Join-Path -Path $devPlaygroundPath -ChildPath "shared"

# Create a unique instance ID
$instanceId = [guid]::NewGuid().ToString()
$instancePath = Join-Path -Path $devPlaygroundPath -ChildPath $instanceId

# Ensure the shared directory exists
if (-not (Test-Path -Path $sharedPath)) {
    Write-Output "Creating shared folder at $sharedPath"
    New-Item -ItemType Directory -Path $sharedPath
} else {
    Write-Output "Shared folder already exists at $sharedPath"
}

# Create the unique instance folder
Write-Output "Creating instance folder at $instancePath"
New-Item -ItemType Directory -Path $instancePath

# Detect changes and rebuild the image if necessary
# Set the current directory as the path to the Dockerfile
$dockerfilePath = Get-Location
$latestImageId = (docker images -q $imageName)
$buildRequired = $false

if ($latestImageId -eq "") {
    Write-Output "No existing image found. Building image $imageName."
    $buildRequired = $true
} else {
    # Check if there are uncommitted changes or differences since the last build
    $changedFiles = git -C $dockerfilePath diff --name-only HEAD
    if ($changedFiles.Length -gt 0) {
        Write-Output "Changes detected in the repository. Rebuilding the Docker image."
        $buildRequired = $true
    }
}

# Rebuild the image if necessary
if ($buildRequired) {
    docker build -t $imageName $dockerfilePath
} else {
    Write-Output "No changes detected. Using the existing image $imageName."
}

# Run Docker container with the shared and instance-specific volumes
Write-Output "Starting Docker container with shared and instance-specific volumes mounted"
docker run -it --rm `
    -v "${sharedPath}:/workspace/shared" `
    -v "${instancePath}:/workspace/instance" `
    -P `
    $imageName bash
