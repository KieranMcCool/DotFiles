#!/bin/bash

# Convert markdown to PDF using Pandoc LaTeX Docker image
# Usage: md2pdf.sh <markdown-file> [additional pandoc options]

if [ $# -lt 1 ]; then
    echo "Usage: md2pdf.sh <markdown-file> [additional pandoc options]"
    exit 1
fi

markdown_file="$1"
shift  # Remove first argument, keep remaining args for pandoc

if [ ! -f "$markdown_file" ]; then
    echo "Error: File '$markdown_file' not found"
    exit 1
fi

# Get the absolute path and output filename
absolute_path=$(cd "$(dirname "$markdown_file")" && pwd)/$(basename "$markdown_file")
output_file="${absolute_path%.md}.docx"

# Run pandoc in Docker
docker run --rm -v "$(dirname "$absolute_path"):/data" \
    pandoc/latex:latest \
    /data/$(basename "$markdown_file") \
    -o /data/$(basename "$output_file") \
    "$@"

echo "Word doc created: $output_file"
