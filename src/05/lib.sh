#!/bin/bash

# Вывести сообщение об ошибке и выход
print_error() {
    echo "Ошибка: некорректный параметр. Используйте: $0 [1|2|3|4]" >&2
    exit 1
}

# валидация параметра
validate_option() {
    local option=$1
    
    if [[ -z "$option" ]] || ! [[ "$option" =~ ^[1-4]$ ]]; then
        print_error
    fi
}

# проверить существование файлов логов
check_log_files() {
    if ! compgen -G "$LOG_FILES" > /dev/null; then
        echo "Ошибка: файлы логов не найдены в $LOG_DIR" >&2
        exit 1
    fi
}
