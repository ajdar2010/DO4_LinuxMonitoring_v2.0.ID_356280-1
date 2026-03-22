#!/bin/bash
. ./lib.sh

cat /dev/null > report.log

if [ $# -ne 3 ]; then
    echo "Использование: $0 [буквы для папок] [буквы для файлов и расширение] [размер файла в МБ]"
    echo "Пример: $0 az az.az 3МБ"
    exit 1
fi

FOLDER_CHARS="$1"
FILE_CHARS="$2"
FILE_SIZE_PARAM="$3"

validate_all_parameters

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
START_SECONDS=$(date +%s)

log_to_report "START TIME: $START_TIME"
log_to_report "PARAMETERS: folders=$FOLDER_CHARS, files=$FILE_CHARS, size=$FILE_SIZE_PARAM"
log_to_report ""

generate_folders_and_files

END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
END_SECONDS=$(date +%s)
TOTAL_SECONDS=$((END_SECONDS - START_SECONDS))
HOURS=$((TOTAL_SECONDS / 3600))
MINUTES=$(((TOTAL_SECONDS % 3600) / 60))
SECONDS=$((TOTAL_SECONDS % 60))

log_to_report ""
log_to_report "END TIME: $END_TIME"
log_to_report "TOTAL TIME: $(printf "%02d:%02d:%02d" $HOURS $MINUTES $SECONDS)"
log_to_report "TOTAL SECONDS: $TOTAL_SECONDS"

echo "СКРИПТ ВЫПОЛНЕН"
echo "Время начала:    $START_TIME"
echo "Время окончания: $END_TIME"
echo "Общее время:     $(printf "%02d:%02d:%02d" $HOURS $MINUTES $SECONDS)"
echo "Файл отчёта:     $(pwd)/report.log"
