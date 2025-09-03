#!/bin/bash

# This script will take a folder as an argument.
# It will sort all of the files and folders in that folder into buckets based on ther month and year they were last modified.
# It will then move each of those folders into an Archive folder in the same directory as the original folder.
# If the Archive folder does not exist, it will be created.
# The archive folder will contain subfolders named in the format "YYYY-MM" (e.g. "2023-04" for April 2023).
# The script will not archive the Archive folder itself if it is found in the input folder.
# Usage: ./archive-folder.sh /path/to/folder

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "No folder path provided."
    echo "Current working directory: $(pwd)"
    read -p "Do you want to archive the current working directory? (y/N): " response
    
    case "$response" in
        [yY]|[yY][eE][sS])
            TARGET_FOLDER="$(pwd)"
            echo "Using current working directory: $TARGET_FOLDER"
            ;;
        *)
            echo "Operation cancelled."
            echo "Usage: $0 /path/to/folder"
            exit 1
            ;;
    esac
else
    # Get the target folder path from argument
    TARGET_FOLDER="$1"
fi

# Check if the target folder exists
if [ ! -d "$TARGET_FOLDER" ]; then
    echo "Error: Folder '$TARGET_FOLDER' does not exist."
    exit 1
fi

# Convert to absolute path
TARGET_FOLDER=$(realpath "$TARGET_FOLDER")

# Define the archive folder path
ARCHIVE_FOLDER="$TARGET_FOLDER/Archive"

# Create archive folder if it doesn't exist
if [ ! -d "$ARCHIVE_FOLDER" ]; then
    echo "Creating archive folder: $ARCHIVE_FOLDER"
    mkdir -p "$ARCHIVE_FOLDER"
fi

# Function to get YYYY-MM format from file modification time
get_year_month() {
    local file="$1"
    # Get modification time in YYYY-MM format
    date -r "$file" +"%Y-%m"
}

# Counter for processed items
processed_count=0

echo "Processing files and folders in: $TARGET_FOLDER"

# Process each item in the target folder
for item in "$TARGET_FOLDER"/*; do
    # Skip if no files match the pattern (empty directory)
    [ ! -e "$item" ] && continue
    
    # Get the basename of the item
    item_name=$(basename "$item")
    
    # Skip the Archive folder itself
    if [ "$item_name" = "Archive" ]; then
        echo "Skipping Archive folder itself"
        continue
    fi
    
    # Get the year-month for this item
    year_month=$(get_year_month "$item")
    
    # Create the year-month subdirectory in Archive if it doesn't exist
    year_month_dir="$ARCHIVE_FOLDER/$year_month"
    if [ ! -d "$year_month_dir" ]; then
        echo "Creating directory: $year_month_dir"
        mkdir -p "$year_month_dir"
    fi
    
    # Move the item to the appropriate year-month directory
    echo "Moving '$item_name' to $year_month/"
    mv "$item" "$year_month_dir/"
    
    # Increment counter
    ((processed_count++))
done

echo "Archive complete! Processed $processed_count items."
echo "Items have been organized by modification date in: $ARCHIVE_FOLDER"
