#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/clean_log.sh"
source "$SCRIPT_DIR/clean_time.sh"
source "$SCRIPT_DIR/clean_mask.sh"

if [ $# -ne 1 ]; then
    echo "Использование: $0 <метод>"
    echo "Методы:"
    echo "1 - Очистка по логу"
    echo "2 - Очистка по времени"
    echo "3 - Очистка по маске"
    exit 1
fi

method=$1

if [[ ! "$method" =~ ^[1-3]$ ]]; then
    echo "Ошибка: Метод должен быть 1-3"
    exit 1
fi

case $method in
    1)
        clean_by_log
        ;;
    2)
        clean_by_time
        ;;
    3)
        clean_by_mask
        ;;
esac




