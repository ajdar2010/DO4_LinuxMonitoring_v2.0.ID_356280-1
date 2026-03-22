#!/bin/bash

function clean_by_log() {
    local log_file="../02/report.log"
    
    if [ ! -f "$log_file" ]; then
        echo "Ошибка: Лог-файл $log_file не найден"
        exit 1
    fi

    local deleted_folders=0
    local deleted_files=0
    
    echo "Очистка по лог-файлу"
    echo "Чтение файла: $log_file"
    echo ""
    
    # читаем строки с FOLDER:
    while IFS= read -r line; do
        if [[ $line =~ ^FOLDER:\ (.+),\ DATE ]]; then
            dir="${BASH_REMATCH[1]}"
            if [ -d "$dir" ]; then
                echo "  Удаление папки: $dir"
                rm -rf "$dir"
                ((deleted_folders++))
            fi
        fi
    done < "$log_file"
    
    # читаем строки с FILE:
    while IFS= read -r line; do
        if [[ $line =~ ^FILE:\ (.+),\ DATE ]]; then
            file="${BASH_REMATCH[1]}"
            if [ -f "$file" ]; then
                echo "  Удаление файла: $file"
                rm -f "$file"
                ((deleted_files++))
            fi
        fi
    done < "$log_file"
    
    # удаляем все логи из папки 02
    local log_dir="../02"
    if [ -d "$log_dir" ]; then
        while IFS= read -r log_path; do
            if [ -n "$log_path" ] && [ -f "$log_path" ]; then
                echo "  Удаление лога: $log_path"
                rm -f "$log_path"
                ((deleted_files++))
            fi
        done < <(find "$log_dir" -maxdepth 1 -name "*.log" 2>/dev/null)
    fi
    
    echo ""
    echo "Очистка завершена."
    echo "Удалено папок: $deleted_folders"
    echo "Удалено файлов: $deleted_files"
}