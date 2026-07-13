#!/usr/bin/env bash

IN_DIR="."
OUT_DIR="."
VERIFY=false


while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
	    IN_DIR="$2"
	    shift 2
	    ;;
        -o|--output)
	    OUT_DIR="$2"
	    shift 2
	    ;;
        --verify)
	    VERIFY=true
	    shift
	    ;;
    esac
done


if [[ ! -d "$IN_DIR" ]]; then
    echo "'$IN_DIR' is not a valid directory. Exiting." >&2
    exit 1
elif [[ ! -d "$OUT_DIR" ]]; then
    echo "'$OUT_DIR' is not a valid directory. Exiting." >&2
    exit 1
else
    echo "Finding flac files in: $IN_DIR"
    echo "Converting them to m4a files in: $OUT_DIR"
fi

FIND_ARGS=(-type f -iname "*.flac")

mapfile -d '' FLAC_FILES < <(find "$IN_DIR" "${FIND_ARGS[@]}" -print0)

TOTAL=${#FLAC_FILES[@]}

if [[ "$TOTAL" -eq 0 ]]; then
    echo "No .flac files found in '$IN_DIR' -- exiting"
    echo
    exit 0
fi


if $verify; then
	NEED_CONVERT=0
	CONVERSION_FILES=()
	for IN_FILE in "${FLAC_FILES[@]}"; do
		base="${IN_FILE%.flac}"
		itunes_readable="${base/FLAC/M4A}.m4a"
		#echo "searching for $itunes_readable"
		if [[ ! -f $itunes_readable ]]; then
			echo "Could not find $itunes_readable"
			CONVERSION_FILES+=("$IN_FILE")
			((NEED_CONVERT++))
		fi
	done
	if [[ $NEED_CONVERT -gt 0 ]]; then
		echo "Found $NEED_CONVERT files in need of conversion"
		read -r -n 1 -p  "Would you like to convert them now? (y/n): " choice
		echo
		echo
		if [[ ! $choice =~ ^[Yy] ]]; then
			echo "Exiting Now"
			exit 0
		fi
		FLAC_FILES=("${CONVERSION_FILES[@]}")
		TOTAL=${#FLAC_FILES[@]}
		echo "TOTAL IS CURRRENTLY $TOTAL"
	else
		echo "No unmatched flac files found"
		exit 0
	fi
fi


read -r -n 1 -p "Converting $TOTAL .flac file(s). Proceed? (y/n): " choice
echo
echo
if [[ ! $choice =~ ^[Yy]$ ]]; then
    echo "Exiting Now"
    exit 0
fi

echo

COUNT=0
FAILED=0

for IN_FILE in "${FLAC_FILES[@]}"; do
    ((COUNT++))
    FILENAME="${IN_FILE##*/}"
    OUT_FILENAME="${FILENAME%.*}.m4a"
    OUT_FILE="${OUT_DIR%/}/$OUT_FILENAME"
    


    echo "[$COUNT/$TOTAL] Converting:	$IN_FILE"
#    echo "Will now be:			$OUT_FILE"
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
