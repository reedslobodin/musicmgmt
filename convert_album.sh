#!/usr/bin/env bash

DIR="${1:-.}"

if [[ ! -d "$DIR" ]]; then
    echo "'$DIR' is not a valid directory. Exiting." >&2
    exit 1
fi

FIND_ARGS=(-type f -iname "*.flac")

mapfile -d '' FLAC_FILES < <(find "$DIR" "${FIND_ARGS[@]}" -print0)

TOTAL=${#FLAC_FILES[@]}

if [[ "$TOTAL" -eq 0 ]]; then
    echo "No .flac files found in '$DIR' -- exiting"
    echo
    exit 0
fi

read -r -n 1 -p "Found $TOTAL .flac file(s). Proceed? (y/n): " choice
echo
echo
if [[ $choice =~ ^[Nn]$ ]]; then
    echo "Exiting Now"
    exit 1
fi

echo

COUNT=0
FAILED=0

for IN_FILE in "${FLAC_FILES[@]}"; do
    ((COUNT++))
    OUT_FILE="${IN_FILE%.*}.m4a"

    echo "[$COUNT/$TOTAL] Converting:	$IN_FILE"
    if ffmpeg -loglevel error -nostdin -hide_banner\
	-i "$IN_FILE" -c:v copy -c:a alac -vn "$OUT_FILE"; then
        echo "Successfully Converted:	$OUT_FILE"
    else
	echo "FAILED:	$OUT_FILE" >&2
	((FAILED++))
	echo "FAILED: $FAILED"
    fi
done

echo
echo "Done Converting: $((TOTAL-FAILED))/$TOTAL successful"

if [[ "$FAILED" -gt 0 ]]; then
	echo "$FAILED file(s) failed to convert." >&2
	exit 1
fi
