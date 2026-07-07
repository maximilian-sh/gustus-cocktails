#!/bin/bash
# Batch-processes raw Gemini cocktail renders into final transparent app assets.
#
# Usage:
#   scripts/process-images.sh <input-dir> [output-dir]
#
# Safety: only files whose (normalized) name matches one of the known cocktail
# IDs below are touched. Everything else in <input-dir> is left completely
# alone and just reported as skipped. This is deliberate: <input-dir> is
# usually the user's ~/Downloads folder, which is full of unrelated files.
#
# Matching is fuzzy (scripts/match_cocktail.py, difflib-based): lowercase,
# strip spaces/underscores/hyphens/apostrophes, then match against the known
# cocktail IDs allowing small typos. So "Espresso Martini.png",
# "espresso-martini.PNG", and even "expresso martni.png" all resolve to the
# canonical "espressoMartini" cocktail id. Output filenames are always the
# canonical camelCase id -- typos never leak into the repo.
#
# For each match, writes <output-dir>/<cocktailId>.png (background removed,
# trimmed, compressed) and moves the raw original into
# <input-dir>/gustus-processed/ so re-running the script doesn't reprocess it.
#
# Defaults to data/images as the output dir.
#
# Requires: rembg (pipx install "rembg[cli]" && pipx inject rembg onnxruntime),
# ImageMagick (brew install imagemagick).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR="${1:?Usage: process-images.sh <input-dir> [output-dir]}"
OUTPUT_DIR="${2:-$SCRIPT_DIR/../data/images}"
ARCHIVE_DIR="$INPUT_DIR/gustus-processed"
MAX_EDGE=1600

cocktail_id_for() {
    python3 "$SCRIPT_DIR/match_cocktail.py" "$1"
}

mkdir -p "$OUTPUT_DIR" "$ARCHIVE_DIR"

shopt -s nullglob
files=("$INPUT_DIR"/*.png "$INPUT_DIR"/*.PNG)
if [ ${#files[@]} -eq 0 ]; then
    echo "No PNG files found in $INPUT_DIR"
    exit 0
fi

processed=0
skipped=0

for input in "${files[@]}"; do
    base="$(basename "$input" | sed 's/\.[Pp][Nn][Gg]$//')"

    id="$(cocktail_id_for "$base")"
    if [ -z "$id" ]; then
        echo "Skip (no cocktail match): $(basename "$input")"
        skipped=$((skipped + 1))
        continue
    fi

    echo "Processing $(basename "$input") -> $id..."

    tmp="$(mktemp -d)"
    rembg i "$input" "$tmp/nobg.png"

    # rembg sometimes leaves a faint but non-trivial (~30-45% alpha) ghost of
    # Gemini's sparkle watermark in the bottom-right corner, including its
    # soft anti-aliased fringe. It's not always fully transparent, so it can
    # silently balloon the trim bounding box (saw a glass crop 2.5x too wide
    # because of it) or survive as a visible smudge. Our compositions always
    # keep the subject centered with generous margin, so it's safe to
    # unconditionally force the bottom-right 22%x22% corner to transparent
    # before trimming (sized generously to also cover the icon's soft edge).
    dims="$(magick "$tmp/nobg.png" -format "%w %h" info:)"
    w="${dims% *}"; h="${dims#* }"
    rw=$((w * 22 / 100)); rh=$((h * 22 / 100))
    x0=$((w - rw)); y0=$((h - rh))
    magick "$tmp/nobg.png" -alpha extract "$tmp/alpha.png"
    magick -size "${w}x${h}" xc:white -fill black -draw "rectangle $x0,$y0,$w,$h" "$tmp/mask.png"
    magick "$tmp/alpha.png" "$tmp/mask.png" -compose Multiply -composite "$tmp/alpha_clean.png"
    magick "$tmp/nobg.png" "$tmp/alpha_clean.png" -alpha off -compose CopyOpacity -composite "$tmp/clean.png"

    # Plain `-trim` is unreliable here: fully-transparent pixels can carry
    # leftover RGB noise that differs from the corner color, so ImageMagick
    # doesn't consider them trimmable background even though alpha is 0.
    # Compute the crop box from the alpha channel alone instead.
    bbox="$(magick "$tmp/clean.png" -alpha extract -fuzz 5% -trim -format "%wx%h%O" info:)"

    magick "$tmp/clean.png" \
        -crop "$bbox" +repage \
        -resize "${MAX_EDGE}x${MAX_EDGE}>" \
        -strip \
        -define png:compression-level=9 \
        -define png:compression-filter=5 \
        "$OUTPUT_DIR/$id.png"

    rm -rf "$tmp"
    mv "$input" "$ARCHIVE_DIR/"

    echo "  -> $OUTPUT_DIR/$id.png ($(identify -format '%wx%h' "$OUTPUT_DIR/$id.png"))"
    processed=$((processed + 1))
done

echo "Done. Processed $processed, skipped $skipped (untouched)."
