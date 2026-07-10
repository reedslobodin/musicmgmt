#!/usr/bin/env bash


need_convert=0

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

for IN_FILE in "${FLAC_FILES[@]}"; do
    base="${IN_FILE%.flac}"
    folder_replaced="${base/FLAC/M4A}"
    itunes_readable="${folder_replaced}.m4a"
    if [[ ! -f $itunes_readable ]]; then
        echo "$IN_FILE"
	((need_convert++))
    fi
done
if [[ $need_convert -gt 0 ]]; then
    echo "Found $need_convert files in need of conversion"
else
    echo "No unmatched flac files found"
fi

