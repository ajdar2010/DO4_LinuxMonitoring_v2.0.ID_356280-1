#!/bin/bash

function clean_by_time() {
    echo "ОЧИСТКА ПО ДАТЕ И ВРЕМЕНИ"
    echo "Введите время начала (YYYY-MM-DD HH:MM):"
    read -r start_time
    echo "Введите время окончания (YYYY-MM-DD HH:MM):"
    read -r end_time
    
    echo ""

    # проверка формата времени
    if ! date -d "$start_time" >/dev/null 2>&1 || ! date -d "$end_time" >/dev/null 2>&1; then
        echo "Ошибка: Неверный формат времени. Используйте YYYY-MM-DD HH:MM"
        exit 1
    fi

    # проверка логики времени
    start_sec=$(date -d "$start_time" +%s)
    end_sec=$(date -d "$end_time" +%s)
    
    if [ $start_sec -gt $end_sec ]; then
        echo "Ошибка: Время начала не может быть позже времени окончания"
        exit 1
    fi

    local deleted_count=0
    
    echo "Очистка файлов и папок, созданных между $start_time и $end_time..."
    echo ""
    
    # Ищем все файлы и папки, созданные в указанный период
    while IFS= read -r item; do
        if [ -n "$item" ]; then
            if [ -d "$item" ]; then
                echo "  Удаление папки: $item"
            else
                echo "  Удаление файла: $item"
            fi
            rm -rf "$item"
            ((deleted_count++))
        fi
    done < <(find /tmp /var/tmp /home/arrykbla -newermt "$start_time" ! -newermt "$end_time" \( -name "*_[0-9][0-9][0-9][0-9][0-9][0-9]" \) 2>/dev/null)
    
    # Удаляем все логи из папки 02
    local log_dir="../02"
    if [ -d "$log_dir" ]; then
        while IFS= read -r log_path; do
            if [ -n "$log_path" ] && [ -f "$log_path" ]; then
                echo "  Удаление лога: $log_path"
                rm -f "$log_path"
                ((deleted_count++))
            fi
        done < <(find "$log_dir" -maxdepth 1 -name "*.log" 2>/dev/null)
    fi
    
    echo ""
    echo "Очистка завершена."
    echo "Удалено элементов: $deleted_count"
}