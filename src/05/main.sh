#!/bin/bash

# Определяем путь к папке со скриптами
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/config.sh"
source "$BASE_DIR/lib.sh"
source "$BASE_DIR/handlers.sh"

# Проверяем параметры
validate_option "$1"

# Проверяем наличие файлов логов
check_log_files

# Выполняем нужный вариант
dispatch_handler "$1"