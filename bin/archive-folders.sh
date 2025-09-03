#!/bin/bash

# This script calls the archive-folder.sh script on several pre-configured directories
# to help keep common directories organized by archiving files based on modification date.

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_SCRIPT="$SCRIPT_DIR/archive-folder.sh"

# Check if the archive-folder.sh script exists
if [ ! -f "$ARCHIVE_SCRIPT" ]; then
    echo "Error: archive-folder.sh script not found at: $ARCHIVE_SCRIPT"
    exit 1
fi

# Check if the archive-folder.sh script is executable
if [ ! -x "$ARCHIVE_SCRIPT" ]; then
    echo "Error: archive-folder.sh script is not executable. Making it executable..."
    chmod +x "$ARCHIVE_SCRIPT"
fi

# Pre-configured directories to archive
DIRECTORIES=(
    "$HOME/Desktop"
    "$HOME/Downloads"
)

# Function to archive a directory
archive_directory() {
    local dir="$1"
    
    if [ -d "$dir" ]; then
        echo "=========================================="
        echo "Archiving directory: $dir"
        echo "=========================================="
        "$ARCHIVE_SCRIPT" "$dir"
        echo ""
    else
        echo "Skipping '$dir' - directory does not exist"
        echo ""
    fi
}

# Main execution
echo "Archive Folders - Batch Directory Archiver"
echo "This will archive files in common directories by modification date."
echo ""

# Ask for confirmation
read -p "Do you want to proceed with archiving the configured directories? (y/N): " response

case "$response" in
    [yY]|[yY][eE][sS])
        echo "Starting batch archive process..."
        echo ""
        
        # Archive each configured directory
        for dir in "${DIRECTORIES[@]}"; do
            archive_directory "$dir"
        done
        
        echo "=========================================="
        echo "Batch archive process completed!"
        echo "=========================================="
        ;;
    *)
        echo "Operation cancelled."
        exit 0
        ;;
esac