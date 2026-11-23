#!/bin/bash

# -----------------------------------------------------------------------------
# truncate_day_file.sh
#
# Automatically detects minute and second day files, preserves the file header,
# and extracts a rolling time window ending at either the current time or a
# user-specified time.
#
# Supported file types:
#   - 1440 samples/day  (minute data)
#   - 86400 samples/day (second data)
# -----------------------------------------------------------------------------

set -euo pipefail

MAX_HEADER_LINES=150
DEFAULT_WINDOW_MINUTES=40

usage() {
    cat <<EOF
Usage:
  $(basename "$0") -i INPUT_FILE -o OUTPUT_FILE [options]

Trim a day file to a rolling time window whilst preserving the header.

The script automatically detects whether the file contains:

  * 86400 one-second samples per day
  * 1440 one-minute samples per day

and automatically determines the header length.

Required options:

  -i FILE
      Input file.

  -o FILE
      Output file.

Optional options:

  -w MINUTES
      Window length in minutes.
      Default: ${DEFAULT_WINDOW_MINUTES}

  -t HH:MM
      End time of the retained window.

      Examples:
          -t 12:30
          -t 00:15
          -t 23:59

      If omitted, the current local time is used.

  -v
      Verbose output. Displays file type, detected header
      length and retained sample count.

  -h
      Display this help.

Examples:

  Keep the last 40 minutes up to now:

      $(basename "$0") -i input.min -o output.min

  Keep the last 90 minutes up to now:

      $(basename "$0") -i input.min -o output.min -w 90

  Keep data ending at 14:30:

      $(basename "$0") -i input.min -o output.min -t 14:30

  Keep the last 6 hours ending at 18:00:

      $(basename "$0") -i input.min -o output.min -w 360 -t 18:00

  Verbose operation:

      $(basename "$0") -i input.min -o output.min -v

Validation:

  * Header length is determined automatically.
  * Up to ${MAX_HEADER_LINES} header lines are permitted.
  * Files must contain either:
        1440  minute samples
    or  86400 second samples.
  * At least two data samples are always retained.
  * The complete header is always preserved.
EOF
}

INPUT_FILE=""
OUTPUT_FILE=""
WINDOW_MINUTES=$DEFAULT_WINDOW_MINUTES
END_TIME=""
VERBOSE=0

while getopts ":i:o:w:t:hv" opt
do
    case "$opt" in
        i)
            INPUT_FILE="$OPTARG"
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        w)
            WINDOW_MINUTES="$OPTARG"
            ;;
        t)
            END_TIME="$OPTARG"
            ;;
        v)
            VERBOSE=1
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Unknown option: -$OPTARG" >&2
            usage >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    usage >&2
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file not found: $INPUT_FILE" >&2
    exit 1
fi

if ! [[ "$WINDOW_MINUTES" =~ ^[0-9]+$ ]]; then
    echo "Window length must be a positive integer number of minutes." >&2
    exit 1
fi

TOTAL_LINES=$(wc -l < "$INPUT_FILE")

HEADER_LINES=-1
SAMPLES_PER_DAY=-1

for candidate_header in $(seq 0 "$MAX_HEADER_LINES")
do
    data_lines=$((TOTAL_LINES - candidate_header))

    if [ "$data_lines" -eq 86400 ]; then
        HEADER_LINES=$candidate_header
        SAMPLES_PER_DAY=86400
        break
    fi

    if [ "$data_lines" -eq 1440 ]; then
        HEADER_LINES=$candidate_header
        SAMPLES_PER_DAY=1440
        break
    fi
done

if [ "$HEADER_LINES" -lt 0 ]; then
    echo "Not a recognised day file." >&2
    echo "Expected 1440 or 86400 data records with no more than ${MAX_HEADER_LINES} header lines." >&2
    exit 1
fi

if [ -n "$END_TIME" ]; then

    if ! [[ "$END_TIME" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
        echo "Invalid time format: $END_TIME" >&2
        echo "Expected HH:MM" >&2
        exit 1
    fi

    hh=${END_TIME%:*}
    mm=${END_TIME#*:}

    if [ "$hh" -gt 23 ] || [ "$mm" -gt 59 ]; then
        echo "Invalid time: $END_TIME" >&2
        exit 1
    fi

    END_SECS=$((10#$hh * 3600 + 10#$mm * 60))

else

    END_SECS=$((10#$(date +%H) * 3600 \
              + 10#$(date +%M) * 60 \
              + 10#$(date +%S)))

fi

DAY_SECS=86400

if [ "$END_SECS" -lt 0 ]; then
    END_SECS=0
fi

if [ "$END_SECS" -ge "$DAY_SECS" ]; then
    END_SECS=$((DAY_SECS - 1))
fi

WINDOW_SECS=$((WINDOW_MINUTES * 60))
START_SECS=$((END_SECS - WINDOW_SECS))

if [ "$START_SECS" -lt 0 ]; then
    START_SECS=0
fi

if [ "$SAMPLES_PER_DAY" -eq 86400 ]; then
    FIRST_SAMPLE=$START_SECS
    LAST_SAMPLE=$END_SECS
    FILE_TYPE="second"
else
    FIRST_SAMPLE=$((START_SECS / 60))
    LAST_SAMPLE=$((END_SECS / 60))
    FILE_TYPE="minute"
fi

# Always retain at least two samples.
if [ $((LAST_SAMPLE - FIRST_SAMPLE + 1)) -lt 2 ]; then

    FIRST_SAMPLE=$((LAST_SAMPLE - 1))

    if [ "$FIRST_SAMPLE" -lt 0 ]; then
        FIRST_SAMPLE=0
        LAST_SAMPLE=1
    fi

fi

KEEP_FROM=$((HEADER_LINES + FIRST_SAMPLE + 1))
KEEP_TO=$((HEADER_LINES + LAST_SAMPLE + 1))

sed -n \
    "1,${HEADER_LINES}p;${KEEP_FROM},${KEEP_TO}p" \
    "$INPUT_FILE" > "$OUTPUT_FILE"

if [ "$VERBOSE" -eq 1 ]; then

    echo "File type        : ${FILE_TYPE} (${SAMPLES_PER_DAY} samples/day)"
    echo "Header lines     : $HEADER_LINES"
    echo "Window minutes   : $WINDOW_MINUTES"

    if [ -n "$END_TIME" ]; then
        echo "End time         : $END_TIME"
    else
        echo "End time         : current time"
    fi

    echo "Data records kept: $((LAST_SAMPLE - FIRST_SAMPLE + 1))"
    echo "Output file      : $OUTPUT_FILE"

fi
