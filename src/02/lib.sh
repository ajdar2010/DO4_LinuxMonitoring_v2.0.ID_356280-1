#!/bin/bash

FOLDER_NAME_COUNTER=0
FILE_NAME_COUNTER=0

# глобальная переменная для пути папки (результат от create_single_directory)
CREATED_FOLDER_PATH=""

# функции валидации 

function is_english_chars {
    if [[ "$1" =~ ^[a-z]+$ ]]; then
        echo 0
    else
        echo 1
    fi
}

function is_num {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        echo 0
    else
        echo 1
    fi
}

function get_length_string {
    string="$1"
    length=${#string}
    echo $length
}

function check_for_dot {
    if [[ "$1" =~ \. ]]; then
        echo 0
    else
        echo 1
    fi
}

function is_empty_string {
    if [[ -n "$1" ]]; then
        echo 0
    else
        echo 1
    fi
}

function is_mb {
    string="$1"
    if [[ "${string: -2}" =~ "Mb" || "${string: -2}" =~ "mb" ]]; then
        echo 0
    else
        echo 1
    fi
}

function validate_folder_chars {
    if [ "$(is_english_chars "$FOLDER_CHARS")" -ne 0 ]; then
        echo "ОШИБКА: символы папки должны содержать только строчные английские буквы."
        exit 1
    fi

    if [ "$(get_length_string "$FOLDER_CHARS")" -gt 7 ]; then
        echo "ОШИБКА: количество символов папки не должно превышать 7 символов."
        exit 1
    fi

    if [ "$(get_length_string "$FOLDER_CHARS")" -lt 1 ]; then
        echo "ОШИБКА: количество символов папки должно быть не менее 1 символа."
        exit 1
    fi
}

function validate_file_chars_format {
    if [ "$(check_for_dot "$FILE_CHARS")" -ne 0 ]; then
        echo "ОШИБКА: формат символов файла должен быть name.ext (с точкой)."
        exit 1
    fi

    FILE_CHARS_NAME=$(echo "$FILE_CHARS" | cut -d'.' -f1)
    FILE_CHARS_EXT=$(echo "$FILE_CHARS" | cut -d'.' -f2)

    if [ "$(is_empty_string "$FILE_CHARS_NAME")" -ne 0 ]; then
        echo "ОШИБКА: символы имени файла не могут быть пустыми."
        exit 1
    fi

    if [ "$(is_empty_string "$FILE_CHARS_EXT")" -ne 0 ]; then
        echo "ОШИБКА: символы расширения файла не могут быть пустыми."
        exit 1
    fi
}

function validate_file_name_chars {
    if [ "$(is_english_chars "$FILE_CHARS_NAME")" -ne 0 ]; then
        echo "ОШИБКА: символы имени файла должны содержать только строчные английские буквы."
        exit 1
    fi

    if [ "$(get_length_string "$FILE_CHARS_NAME")" -gt 7 ]; then
        echo "ОШИБКА: количество символов имени файла не должно превышать 7 символов."
        exit 1
    fi

    if [ "$(get_length_string "$FILE_CHARS_NAME")" -lt 1 ]; then
        echo "ОШИБКА: количество символов имени файла должно быть не менее 1 символа."
        exit 1
    fi
}

function validate_file_ext_chars {
    if [ "$(is_english_chars "$FILE_CHARS_EXT")" -ne 0 ]; then
        echo "ОШИБКА: символы расширения файла должны содержать только строчные английские буквы."
        exit 1
    fi

    if [ "$(get_length_string "$FILE_CHARS_EXT")" -gt 3 ]; then
        echo "ОШИБКА: количество символов расширения файла не должно превышать 3 символов."
        exit 1
    fi

    if [ "$(get_length_string "$FILE_CHARS_EXT")" -lt 1 ]; then
        echo "ОШИБКА: количество символов расширения файла должно быть не менее 1 символа."
        exit 1
    fi
}

function validate_file_size {
    if [ "$(is_mb "$FILE_SIZE_PARAM")" -ne 0 ]; then
        echo "ОШИБКА: размер файла должен быть указан в формате Mb (например, 3Mb)."
        exit 1
    fi

    FILE_SIZE_NUM="${FILE_SIZE_PARAM: 0: -2}"

    if [ "$(is_num "$FILE_SIZE_NUM")" -ne 0 ]; then
        echo "ОШИБКА: число размера файла должно быть числовым."
        exit 1
    fi

    if [[ "$FILE_SIZE_NUM" -le 0 || "$FILE_SIZE_NUM" -gt 100 ]]; then
        echo "ОШИБКА: размер файла должен быть от 1 до 100 Mb."
        exit 1
    fi
}

function validate_all_parameters {
    validate_folder_chars
    validate_file_chars_format
    validate_file_name_chars
    validate_file_ext_chars
    validate_file_size
}

# ################################################################

# проверить наличие свободного места (> 1GB)
function check_memory {
    # получить доступное место в килобайтах
    avail_kb=$(df -k / | tail -1 | awk '{print $4}')
    error="0"
    
    # проверить меньше ли 1GB (1048576 KB)
    if [ "$avail_kb" -lt 1048576 ]; then
        error="1"
    fi
    
    echo "$error"
}

# функция для проверки памяти
function check_memory_and_exit_if_full {
    if [ $(check_memory) -eq 1 ]; then
        log_to_report "MEMORY FULL: Available space is less than 1GB. Stopping."
        return 1
    fi
    return 0
}

# записать результаты в report.log
function log_to_report {
    local entry="$1"
    echo "$entry" >> report.log
}

function generate_name {
    local chars="$1"
    local counter="$2"
    
    # получить отсортированные уникальные символы
    local sorted_unique="$(echo "$chars" | fold -w1 | sort -u | tr -d '\n')"
    
    # если счётчик 0, не добавляем дополнительные символы
    if [ $counter -eq 0 ]; then
        echo "$sorted_unique"
        return
    fi
    
    # построить полную строку путём подсчёта
    local num_unique=${#sorted_unique}
    local current_string="$sorted_unique"
    
    # просто добавляем символы циклически - они остаются отсортированными естественно!
    for ((i=0; i<counter; i++)); do
        local char_index=$((i % num_unique))
        current_string="${current_string}${sorted_unique:$char_index:1}"
    done
    
    # отсортировать финальную строку
    current_string="$(echo "$current_string" | fold -w1 | sort | tr -d '\n')"
    echo "$current_string"
}

# вспомогательная функция для создания файла
function create_single_file {
    local filename="${1}_$(date +"%d%m%y").${FILE_CHARS_EXT}"
    local file_size_bytes=$((FILE_SIZE_NUM * 1024 * 1024))
    
    # проверить, был ли файл успешно создан
    if ! dd if=/dev/zero of="$dir_path"/"$filename" bs=1M count="$FILE_SIZE_NUM" status=none 2>/dev/null; then
        return 1
    fi
    
    # проверить, был ли файл действительно создан с правильным размером
    if [ ! -f "$dir_path"/"$filename" ]; then
        return 1
    fi
    
    local log_entry="FILE: $dir_path/$filename, DATE: $(date +"%Y-%m-%d %H:%M:%S"), SIZE: ${FILE_SIZE_NUM}Mb"
    log_to_report "$log_entry"
    
    ((++FILE_NAME_COUNTER))
    return 0
}

# вспомогательная функция для создания папки
function create_single_directory {
    local dirname="${1}_$(date +"%d%m%y")"
    mkdir -p "$base_path"/"$dirname" 2>/dev/null

    local log_entry="FOLDER: $base_path/$dirname, DATE: $(date +"%Y-%m-%d %H:%M:%S")"
    log_to_report "$log_entry"
    
    ((++FOLDER_NAME_COUNTER))
    
    # установить глобальную переменную вместо вывода
    CREATED_FOLDER_PATH="$base_path"/"$dirname"
    return 0
}

function generate_folders_and_files {
    local search_dirs=()
    local candidate_dirs=("/tmp" "/var/tmp" "/home" "$HOME")
    
    # Найти доступные для записи папки
    for dir in "${candidate_dirs[@]}"; do
        if [ -d "$dir" ] && [ -w "$dir" ] 2>/dev/null; then
            search_dirs+=("$dir")
        fi
    done
    
    if [ ${#search_dirs[@]} -eq 0 ]; then
        echo "ОШИБКА: не найдено доступных для записи каталогов."
        exit 1
    fi

    log_to_report "AVAILABLE DIRECTORIES: ${search_dirs[*]}"
    log_to_report ""

    local folder_count=0
    local file_count=0
    local folder_name_counter=0
    local max_folders=100
    local last_folder_path=""
    
    # Создавать папки и файлы, пока не закончится место (< 1GB) или не достигнем максимум папок
    while [ $(check_memory) -eq 0 ] && [ $folder_count -lt $max_folders ]; do
        # Выбрать случайную базовую папку
        local base_path="${search_dirs[$((RANDOM % ${#search_dirs[@]}))]}"
        
        # Генерировать имя папки с использованием локального счётчика
        local folder_name=$(generate_name "$FOLDER_CHARS" "$folder_name_counter")
        
        create_single_directory "$folder_name"
        local dir_path="$CREATED_FOLDER_PATH"
        last_folder_path="$dir_path"
        
        ((folder_count++))
        ((folder_name_counter++))
        
        # генерировать файлы для этой папки
        # генерировать 1-15 случайных файлов
        local num_files=$((RANDOM % 15 + 1))
        local file_name_counter=0
        
        for (( i=0; i<num_files; i++ )); do
            # проверить, заканчивается ли место (менее 1GB)
            if [ $(check_memory) -ne 0 ]; then
                break 2
            fi
            
            # генерировать имя файла с использованием локального счётчика для этой папки
            local file_name_part=$(generate_name "$FILE_CHARS_NAME" "$file_name_counter")
            if create_single_file "$file_name_part" 2>/dev/null; then
                ((file_count++))
                ((file_name_counter++))
            fi
        done
    done
    
    # если создано 100 папок и место осталось, заполнить последнюю папку файлами
    if [ $folder_count -eq $max_folders ] && [ -d "$last_folder_path" ] && [ $(check_memory) -eq 0 ]; then
        local dir_path="$last_folder_path"
        local file_name_counter=0
        
        while [ $(check_memory) -eq 0 ]; do
            # Генерировать имя файла с использованием локального счётчика
            local file_name_part=$(generate_name "$FILE_CHARS_NAME" "$file_name_counter")
            if create_single_file "$file_name_part" 2>/dev/null; then
                ((file_count++))
                ((file_name_counter++))
            else
                break
            fi
        done
    fi
    
    log_to_report ""
    log_to_report "FOLDERS CREATED: $folder_count"
    log_to_report "FILES CREATED: $file_count"
}