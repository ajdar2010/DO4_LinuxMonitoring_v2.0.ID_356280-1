#!/bin/bash

# получаем директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# загружаем конфигурацию и функции
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib.sh"

# главная функция
function main() {
   
    echo "ГЕНЕРАТОР ЛОГОВ"
    echo "Генерирование $DAYS_COUNT файлов логов..."
    echo "Период: $START_DATE - $(date -d "$START_DATE + $((DAYS_COUNT - 1)) days" +"%Y-%m-%d")"
    echo ""
    
    # генерируем логи за каждый день
    for day in $(seq 1 $DAYS_COUNT); do
        generate_logs_for_day "$day"
    done
    
    # выводим статистику
    print_statistics
}

main
