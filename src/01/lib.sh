# функции валидации #####################
function is_unique_chars {
    local str="$1"
    if [[ $(echo "$str" | fold -w1 | sort | uniq -d | wc -l) -eq 0 ]]; then
        echo 0  # все символы уникальны
    else
        echo 1  # есть повторения
    fi
}

function is_english_chars {
    if [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
        echo 0
    else
        echo 1
    fi
}

function is_num {
    if [[ "$1" =~ ^-?[0-9]+$ ]]; then
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

function get_date {
    echo "$(date +"%d%m%y")"
}

function is_kb {
    string="$1"
    if [[ "${string: -2}" =~ "kb" ]]; then
        echo 0
    else
        echo 1
    fi
}

function validate_path {
    if [[ "${FOLDER_PATH: 0: 1}" != "/" ]]; then 
        echo "ОШИБКА: $FOLDER_PATH не является абсолютным путём. "
        exit 1
    fi

    if [ ! -d "$FOLDER_PATH" ]; then
        echo "ОШИБКА: $FOLDER_PATH не является корректным путём. "
        exit 1
    fi
}

function validate_folder_depth {
    if [ $(is_num "$FOLDER_DEPTH") -ne 0 ]; then
        echo "ОШИБКА: глубина папок должна быть числом. "
        exit 1
    fi

    if [ "$FOLDER_DEPTH" -le 0 ]; then
        echo "ОШИБКА: глубина папок должна быть больше 0. "
        exit 1
    fi
}

function validate_folder_chars {
    if [ "$(is_english_chars "$FOLDER_CHARS")" -ne 0 ]; then
        echo "ОШИБКА: символы в строке символов папки должны быть только английскими буквами. "
        exit 1
    fi

    if [ "$(is_unique_chars "$FOLDER_CHARS")" -ne 0 ]; then
        echo "ОШИБКА: символы в строке символов папки должны быть уникальными. "
        exit 1
    fi

    if [ "$(get_length_string "$FOLDER_CHARS")" -gt 7 ]; then
        echo "ОШИБКА: в строке символов должно быть не более 7 символов. "
        exit 1
    fi
}

function validate_file_count {
    if [ $(is_num "$FILE_COUNT") -ne 0 ]; then
        echo "ОШИБКА: количество файлов должно быть числом. "
        exit 1
    fi

    if [ "$FILE_COUNT" -le 0 ]; then
        echo "ОШИБКА: в папке должен быть как минимум 1 файл"
        exit 1
    fi
}

function validate_file_chars_format {
    if [ "$(check_for_dot "$FILE_CHARS")" -ne 0 ]; then
        echo "ОШИБКА: неверный формат списка символов для имени файла. "
        exit 1
    fi

    FILE_CHARS_NAME=$(echo "$FILE_CHARS" | cut -d'.' -f1)
    FILE_CHARS_EXT=$(echo "$FILE_CHARS" | cut -d'.' -f2)

    if [ "$(is_empty_string "$FILE_CHARS_NAME")" -ne 0 ]; then
        echo "ОШИБКА: неверный список символов для имени файла. "
        exit 1
    fi

    if [ "$(is_empty_string "$FILE_CHARS_EXT")" -ne 0 ]; then
        echo "ОШИБКА: неверный список символов для расширения файла. "
        exit 1
    fi
}

function validate_file_name_chars {
    if [ "$(is_english_chars "$FILE_CHARS_NAME")" -ne 0 ]; then
        echo "ОШИБКА: символы в строке символов имени файла должны быть только английскими буквами. "
        exit 1
    fi

    if [ "$(is_unique_chars "$FILE_CHARS_NAME")" -ne 0 ]; then
        echo "ОШИБКА: символы в строке символов имени файла должны быть уникальными. "
        exit 1
    fi

    if [ "$(get_length_string "$FILE_CHARS_NAME")" -gt 7 ]; then
        echo "ОШИБКА: в строке символов имени файла должно быть не более 7 символов. "
        exit 1
    fi
}

function validate_file_ext_chars {
    if [ "$(is_english_chars "$FILE_CHARS_EXT")" -ne 0 ]; then
        echo "ОШИБКА: символы в строке символов расширения файла должны быть только английскими буквами. "
        exit 1
    fi

    if [ "$(is_unique_chars "$FILE_CHARS_EXT")" -ne 0 ]; then
        echo "ОШИБКА: символы в строке символов расширения файла должны быть уникальными. "
        exit 1
    fi

    if [ "$(get_length_string "$FILE_CHARS_EXT")" -gt 3 ]; then
        echo "ОШИБКА: в строке символов расширения файла должно быть не более 3 символов. "
        exit 1
    fi
}

function validate_file_size {
    if [ "$(is_kb "$FILE_SIZE")" -ne 0 ]; then
        echo "ОШИБКА: размер файла должен быть в формате kb. "
        exit 1
    fi

    FILE_SIZE_NUM="${FILE_SIZE: 0: -2}"

    if [[ "$FILE_SIZE_NUM" -le 0 || "$FILE_SIZE_NUM" -gt 100 ]]; then
        echo "ОШИБКА: размер файла должен быть между 1 и 100kb. "
        exit 1
    fi
}

function validate_all_parameters {
    validate_path
    validate_folder_depth
    validate_folder_chars
    validate_file_count
    validate_file_chars_format
    validate_file_name_chars
    validate_file_ext_chars
    validate_file_size
}
# ################################################################

function validate_name_length {
    local name="$1"
    local type="$2"  # "файл" или "директория"
    
    if [ ${#name} -gt 255 ]; then
        echo "ОШИБКА: имя $type '$name' превышает 255 символов (${#name} > 255)"
        exit 1
    fi
}

# Проверить, есть ли >1gb памяти на /
function check_memory() {
    # Получить доступное место в килобайтах
    avail_kb=$(df -k / | tail -1 | awk '{print $4}')
    error="0"
    
    # Проверить, менее ли 1GB (1048576 KB)
    if [ "$avail_kb" -lt 1048576 ]; then
        error="1"
    fi
    
    echo "$error"
}

# Вспомогательная функция для проверки памяти
function check_memory_and_exit_if_full {
    if [ $(check_memory) -eq 1 ]; then
        echo "Память заполнена"
        exit 1
    fi
}

# Записать результаты в report.log
function log_to_report {
    local entry="$1"
    echo "$entry" >> report.log
}

# Вспомогательная функция для создания файла
function create_single_file {
    local filename="${1}_$(date +"%d%m%y").${file_ext}"
    validate_name_length "$filename" "File"
    fallocate -l "$file_size" "$dir_path"/"$filename"

    local log_entry="PATH: $dir_path/$filename, DATE: $(date +"%d:%m:%y"), NAME: $filename, SIZE: $file_size"
    log_to_report "$log_entry"
}

# Вспомогательная функция для создания директории
function create_single_directory {
    local dirname="${1}_$(date +"%d%m%y")"
    validate_name_length "$dirname" "Directory"
    mkdir -p "$base_path"/"$dirname"

    local log_entry="PATH: $base_path/$dirname, DATE: $(date +"%d:%m:%y"), NAME: $dirname, SIZE: -"
    log_to_report "$log_entry"

    echo "$base_path"/"$dirname"
}

function generate_files {
    local dir_path="$1"
    local string="$(echo "$2" | fold -w1 | sort | tr -d '\n')"
    local file_ext="$3"
    local file_count="$4"
    local file_size="$5"
    local counter=0
    local chars=()
    
    # Преобразовать в массив символов
    for ((i=0; i<${#string}; i++)); do
        chars+=("${string:$i:1}")
    done

    # Проверить память один раз в начале
    check_memory_and_exit_if_full

    # Если исходная строка уже ≥4, создать файл
    if [ ${#string} -ge 4 ]; then
        create_single_file "$string"
        ((counter++))
    fi

    # Генерировать оставшиеся имена
    local char_index=0
    while [ $counter -lt $file_count ]; do
        check_memory_and_exit_if_full
        
        # Добавить следующий символ
        string="${string}${chars[char_index]}"
        string="$(echo "$string" | fold -w1 | sort | tr -d '\n')"
        
        # Перейти к следующему символу (цикл с модулем)
        char_index=$(( (char_index + 1) % ${#chars[@]} ))
        
        # Создавать только если длина ≥4
        if [ ${#string} -ge 4 ]; then
            create_single_file "$string"
            ((counter++))
        fi
    done
}

function generate_directories {
    local base_path="$1"
    local folder_depth="$2"
    local folder_chars="$3"
    local counter=0
    local chars=()

    # Отсортировать folder_chars первоначально
    local sorted_chars="$(echo "$folder_chars" | fold -w1 | sort | tr -d '\n')"
    
    # Преобразовать в массив символов
    for ((i=0; i<${#sorted_chars}; i++)); do
        chars+=("${sorted_chars:$i:1}")
    done

    # Если исходная строка уже ≥4, создать первую папку
    if [ ${#sorted_chars} -ge 4 ]; then
        local dir_path=$(create_single_directory "$sorted_chars")
        generate_files "$dir_path" "$FILE_CHARS_NAME" "$FILE_CHARS_EXT" "$FILE_COUNT" "$FILE_SIZE"
        ((counter++))
    fi

    local char_index=0
    local current_string="$sorted_chars"  # Использовать отдельную переменную для построения
    
    # Генерировать оставшиеся папки (все на одном уровне базы)
    while [ $counter -lt $folder_depth ]; do
        # Добавить следующий символ
        current_string="${current_string}${chars[char_index]}"
        current_string="$(echo "$current_string" | fold -w1 | sort | tr -d '\n')"
        
        # Перейти к следующему символу (цикл с модулем)
        char_index=$(( (char_index + 1) % ${#chars[@]} ))
        
        # Создавать только если длина ≥4
        if [ ${#current_string} -ge 4 ]; then
            local dir_path=$(create_single_directory "$current_string")
            generate_files "$dir_path" "$FILE_CHARS_NAME" "$FILE_CHARS_EXT" "$FILE_COUNT" "$FILE_SIZE"
            ((counter++))
        fi
    done
}