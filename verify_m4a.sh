#!/usr/bin/env bash


need_convert=false

DIR="${1:-.}"

find . -type f -name "*.flac" | while read -r flac; do
    base="${flac%.flac}"
    if [[ ! -f "${base}.m4a" ]]; then
        echo "$flac"
	need_convert = true
    fi
done
if ! $need_convert; then
	echo "No unmatched flac files found"
fi
