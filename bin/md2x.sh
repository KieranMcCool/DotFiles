#!/bin/bash

# Convert markdown to various formats using Pandoc LaTeX Docker image
# Usage: md2x.sh <markdown-file> <format> [additional pandoc options]
# Formats: pdf, docx, pptx

if [ $# -lt 2 ]; then
    echo "Usage: md2x.sh <markdown-file> <format> [additional pandoc options]"
    echo "Formats: pdf, docx, pptx"
    exit 1
fi

markdown_file="$1"
format="$2"
shift 2

if [ ! -f "$markdown_file" ]; then
    echo "Error: File '$markdown_file' not found"
    exit 1
fi

case "$format" in
    pdf|docx|pptx) ;;
    *)
        echo "Error: Unsupported format '$format'. Use pdf, docx, or pptx."
        exit 1
        ;;
esac

absolute_path=$(cd "$(dirname "$markdown_file")" && pwd)/$(basename "$markdown_file")
output_file="${absolute_path%.md}.$format"

docker run --rm -v "$(dirname "$absolute_path"):/data" \
    pandoc/extra:latest \
    /data/$(basename "$markdown_file") \
    -o /data/$(basename "$output_file") \
    "$@"

echo "${format^^} created: $output_file"
