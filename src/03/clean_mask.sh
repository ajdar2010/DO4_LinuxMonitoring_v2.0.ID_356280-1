#!/bin/bash

# например: aaazzzz_150326, abbb_150326 и т.д.
function clean_by_mask() {
    echo "ОЧИСТКА ПО МАСКЕ ИМЕНИ"
    echo "Маска: [буквы]_[DDMMYY]"
    echo "Примеры: aaazzzz_150326, abbb_150326"
    echo ""
    
    local deleted_dirs=0
    local deleted_files=0
    
    echo "Поиск и удаление элементов по маске..."
    echo ""
    
    # ищем все элементы, соответствующие маске в основных папках
    for path in /tmp /var/tmp /home/arrykbla; do
        if [ ! -d "$path" ]; then
            continue
        fi
        
        # Маска: строчные буквы, нижнее подчеркивание, 6 цифр (дата в формате DDMMYY)
        while IFS= read -r item; do
            if [ -n "$item" ] && [ -e "$item" ]; then
                if [ -d "$item" ]; then
                    echo "  Удаление папки: $item"
                    rm -rf "$item"
                    ((deleted_dirs++))
                else
                    echo "  Удаление файла: $item"
                    rm -f "$item"
                    ((deleted_files++))
                fi
            fi
        done < <(find "$path" -maxdepth 1 \( -name "[a-z]*_[0-9][0-9][0-9][0-9][0-9][0-9]" -o -name "[a-z]*_[0-9][0-9][0-9][0-9][0-9][0-9]/*" \) 2>/dev/null)
    done
    
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
    echo "Удалено папок: $deleted_dirs"
    echo "Удалено файлов: $deleted_files"
}