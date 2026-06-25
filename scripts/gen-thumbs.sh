#!/usr/bin/env bash

# Bulk-generate square center-crop thumbnails with _thumb suffix.
# Usage: gen-thumbs <directory> [size]
#   directory  -- path to directory containing images
#   size       -- thumbnail width/height in pixels (default: 150)
set -uo pipefail

DIR="${1:?Usage: gen-thumbs <directory> [size]}"
SIZE="${2:-150}"

if ! command -v convert &>/dev/null; then
    echo "error: ImageMagick 'convert' not found in PATH" >&2
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo "error: '$DIR' is not a directory" >&2
    exit 1
fi

count=0
shopt -s nullglob

for img in "$DIR"/*.jpg "$DIR"/*.jpeg "$DIR"/*.png "$DIR"/*.JPG "$DIR"/*.JPEG "$DIR"/*.PNG; do
    [ -f "$img" ] || continue
    # Skip existing thumbnails
    [[ "$img" == *_thumb.* ]] && continue
    stem="${img%.*}"
    thumb="${stem}_thumb.jpg"
    if ! convert "$img" \
        -resize "${SIZE}x${SIZE}^" \
        -gravity center \
        -extent "${SIZE}x${SIZE}" \
        -quality 82 \
        "$thumb" 2>/dev/null; then
        echo "warning: failed to convert $img" >&2
        continue
    fi
    # Verify thumbnail was actually created
    [ -s "$thumb" ] || {
        echo "warning: empty thumbnail for $img" >&2
        continue
    }
    echo "  $thumb"
    ((++count))
done

echo "Generated $count thumbnails"