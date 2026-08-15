#!/usr/bin/env bash
# Convert a screen recording to a muted WebM.
# Usage: ./convert-demo.sh <input-file>

set -euo pipefail

OUTPUT_DIR="."

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input-file>"
    echo "Example: $0 recording.mkv"
    exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
    echo "Error: $INPUT not found"
    exit 1
fi

DEFAULT_NAME="$(basename "${INPUT%.*}")"
read -rp "Output name [$DEFAULT_NAME]: " NAME
NAME="${NAME:-$DEFAULT_NAME}"

mkdir -p "$OUTPUT_DIR"

echo "Generating muted WebM..."
ffmpeg -y -i "$INPUT" \
    -an \
    -c:v libvpx-vp9 -crf 30 -b:v 0 \
    "$OUTPUT_DIR/$NAME.webm"

echo "Done:"
ls -lh "$OUTPUT_DIR/$NAME.webm"
