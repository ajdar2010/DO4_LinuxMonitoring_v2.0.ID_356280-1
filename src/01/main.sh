#!/bin/bash
. ./lib.sh

cat /dev/null > report.log

if [ $# -ne 6 ]; then
    echo "Usage $0 [abs path] [number of dirs] [english chars in dir names] [num of files] [english chars in file name and ext] [filesize in kilobytes]"
    exit 1
fi

FOLDER_PATH="$1"
FOLDER_DEPTH="$2"
FOLDER_CHARS="$3"
FILE_COUNT="$4"
FILE_CHARS="$5"
FILE_SIZE="$6"

validate_all_parameters

generate_directories "$FOLDER_PATH" "$FOLDER_DEPTH" "$FOLDER_CHARS"