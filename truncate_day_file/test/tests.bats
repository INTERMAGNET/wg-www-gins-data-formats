#!/usr/bin/env bats

SCRIPT="truncate_day_file.sh"

setup() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"

    TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

create_minute_file() {
    local file="$1"
    local headers="$2"

    {
        for h in $(seq 1 "$headers")
        do
            echo "HEADER $h"
        done

        for i in $(seq 0 1439)
        do
            printf "MINUTE %04d\n" "$i"
        done
    } > "$file"
}

create_second_file() {
    local file="$1"
    local headers="$2"

    {
        for h in $(seq 1 "$headers")
        do
            echo "HEADER $h"
        done

        for i in $(seq 0 86399)
        do
            printf "SECOND %05d\n" "$i"
        done
    } > "$file"
}

@test "can run the script" {
    run "$SCRIPT" -h
    truncate_day_file.sh -h
}

@test "rejects invalid file" {

    seq 100 > "$TEST_DIR/invalid.dat"

    run "$SCRIPT" \
        -i "$TEST_DIR/invalid.dat" \
        -o "$TEST_DIR/out.dat"

    [ "$status" -ne 0 ]
}

@test "detects minute file with automatic header detection" {

    create_minute_file "$TEST_DIR/minute.dat" 13

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 12:00 \
        -w 60

    [ "$status" -eq 0 ]

    lines=$(wc -l < "$TEST_DIR/out.dat")

    # 13 header lines + 61 samples (11:00-12:00 inclusive)
    [ "$lines" -eq 74 ]
}

@test "detects second file with automatic header detection" {

    create_second_file "$TEST_DIR/second.dat" 25

    run "$SCRIPT" \
        -i "$TEST_DIR/second.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 01:00 \
        -w 1

    [ "$status" -eq 0 ]

    lines=$(wc -l < "$TEST_DIR/out.dat")

    # 25 header + 61 seconds
    [ "$lines" -eq 86 ]
}

@test "retains complete header" {

    create_minute_file "$TEST_DIR/minute.dat" 10

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 12:00 \
        -w 60

    [ "$status" -eq 0 ]

    first=$(head -1 "$TEST_DIR/out.dat")
    tenth=$(sed -n '10p' "$TEST_DIR/out.dat")

    [ "$first" = "HEADER 1" ]
    [ "$tenth" = "HEADER 10" ]
}

@test "window is clamped at start of day for minute file" {

    create_minute_file "$TEST_DIR/minute.dat" 5

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 00:05 \
        -w 60

    [ "$status" -eq 0 ]

    lines=$(wc -l < "$TEST_DIR/out.dat")

    # 5 header + first six minutes (00:00-00:05)
    [ "$lines" -eq 11 ]
}

@test "window is clamped at start of day for second file" {

    create_second_file "$TEST_DIR/second.dat" 3

    run "$SCRIPT" \
        -i "$TEST_DIR/second.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 00:00 \
        -w 40

    [ "$status" -eq 0 ]

    lines=$(wc -l < "$TEST_DIR/out.dat")

    # 3 header + two retained samples minimum
    [ "$lines" -eq 5 ]
}

@test "minimum two samples are retained for minute file" {

    create_minute_file "$TEST_DIR/minute.dat" 7

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 00:00 \
        -w 0

    [ "$status" -eq 0 ]

    lines=$(wc -l < "$TEST_DIR/out.dat")

    [ "$lines" -eq 9 ]
}

@test "minimum two samples are retained for second file" {

    create_second_file "$TEST_DIR/second.dat" 7

    run "$SCRIPT" \
        -i "$TEST_DIR/second.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 00:00 \
        -w 0

    [ "$status" -eq 0 ]

    lines=$(wc -l < "$TEST_DIR/out.dat")

    [ "$lines" -eq 9 ]
}

@test "supports maximum allowed header length" {

    create_minute_file "$TEST_DIR/minute.dat" 150

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 01:00 \
        -w 10

    [ "$status" -eq 0 ]
}

@test "rejects file with too many header lines" {

    create_minute_file "$TEST_DIR/minute.dat" 151

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat"

    [ "$status" -ne 0 ]
}

@test "verbose mode produces summary output" {

    create_minute_file "$TEST_DIR/minute.dat" 13

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -v \
        -t 12:00

    [ "$status" -eq 0 ]

    [[ "$output" =~ "File type" ]]
    [[ "$output" =~ "Header lines" ]]
}

@test "non verbose mode is silent" {

    create_minute_file "$TEST_DIR/minute.dat" 13

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 12:00

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "correct first and last retained minute records" {

    create_minute_file "$TEST_DIR/minute.dat" 4

    run "$SCRIPT" \
        -i "$TEST_DIR/minute.dat" \
        -o "$TEST_DIR/out.dat" \
        -t 12:00 \
        -w 60

    [ "$status" -eq 0 ]

    first_data=$(sed -n '5p' "$TEST_DIR/out.dat")
    last_data=$(tail -1 "$TEST_DIR/out.dat")

    [ "$first_data" = "MINUTE 0660" ]
    [ "$last_data" = "MINUTE 0720" ]
}
