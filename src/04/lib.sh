#!/bin/bash



# функция для генерации случайного IP-адреса
# возвращает: IP 
function generate_ip() {
    local octet1=$((RANDOM % 223 + 1))
    local octet2=$((RANDOM % 256))
    local octet3=$((RANDOM % 256))
    local octet4=$((RANDOM % 256))
    
    echo "$octet1.$octet2.$octet3.$octet4"
}

# функция для получения случайного элемента из массива
# аргумент имя массива
# возвращает один элемент из массива
function get_random_element() {
    local array_name=$1
    local -n array_ref=$array_name
    local index=$((RANDOM % ${#array_ref[@]}))
    echo "${array_ref[$index]}"
}

# функция для генерации случайного размера ответа в байтах
# возвращает число от MIN_RESPONSE_SIZE до MAX_RESPONSE_SIZE
function generate_response_size() {
    local range=$((MAX_RESPONSE_SIZE - MIN_RESPONSE_SIZE + 1))
    echo $((RANDOM % range + MIN_RESPONSE_SIZE))
}

# функция для генерации одной записи лога
# аргументы:
#   $1 - IP адрес
#   $2 - дата в формате ДД/ММ/ГГГГ
#   $3 - время в формате ЧЧ:ММ:СС
#   $4 - HTTP метод
#   $5 - URL
#   $6 - HTTP код ответа
#   $7 - размер ответа
#   $8 - User-Agent
function format_log_entry() {
    local ip=$1
    local log_date=$2
    local time=$3
    local method=$4
    local url=$5
    local status=$6
    local size=$7
    local user_agent=$8
    
    # Referer (случайно "-" или URL)
    local referer="-"
    if [ $((RANDOM % 2)) -eq 0 ]; then
        referer="http://example.com"
    fi
    
    # Формат combined log:
    # IP - - [дата:время +0000] "МЕТОД URL HTTP/1.1" КОД_ОТВЕТА РАЗМЕР "REFERER" "USER-AGENT"
    echo "$ip - - [$log_date:$time +0000] \"$method $url HTTP/1.1\" $status $size \"$referer\" \"$user_agent\""
}

# функция для генерации логов за один день
# аргумент: номер дня (1-5)
function generate_logs_for_day() {
    local day=$1
    local output_file="access_$day.log"
    
    # Преобразуем номер дня в дату
    local log_date=$(date -d "$START_DATE + $((day - 1)) days" +"%d/%b/%Y")
    
    # Количество записей (100-1000)
    local num_entries=$((RANDOM % (MAX_ENTRIES - MIN_ENTRIES + 1) + MIN_ENTRIES))
    
    echo "Генерирование лога $output_file ($num_entries записей)..."
    
    # Время для логов величивается по мере добавления записей
    local current_hour=0
    local current_min=0
    local current_sec=0
    
    > "$output_file"  # Очищаем файл
    
    for ((i = 1; i <= num_entries; i++)); do
        # Генерируем данные для записи
        local ip=$(generate_ip)
        local time_string=$(printf "%02d:%02d:%02d" $current_hour $current_min $current_sec)
        local method=$(get_random_element "HTTP_METHODS")
        local url=$(get_random_element "URLS")
        local status_code=$(get_random_element "HTTP_CODES")
        local response_size=$(generate_response_size)
        local user_agent=$(get_random_element "AGENTS")
        
        # Формируем и записываем лог
        local log_entry=$(format_log_entry "$ip" "$log_date" "$time_string" "$method" "$url" "$status_code" "$response_size" "$user_agent")
        echo "$log_entry" >> "$output_file"
        
        # Увеличиваем время на случайное количество секунд (1-60)
        local time_increment=$((RANDOM % 60 + 1))
        current_sec=$((current_sec + time_increment))
        
        # Переполнение секунд
        if [ $current_sec -ge 60 ]; then
            current_min=$((current_min + current_sec / 60))
            current_sec=$((current_sec % 60))
        fi
        
        # переполнение минут
        if [ $current_min -ge 60 ]; then
            current_hour=$((current_hour + current_min / 60))
            current_min=$((current_min % 60))
        fi
        
        # переполнение часов
        if [ $current_hour -ge 24 ]; then
            current_hour=$((current_hour % 24))
        fi
    done
    
    echo " Создан лог-файл: $output_file ($num_entries записей)"
}

# Функция для вывода статистики
function print_statistics() {
    echo "ГЕНЕРИРОВАНИЕ ЗАВЕРШЕНО"
    echo "Созданные файлы:"
    ls -lh access_*.log 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    echo "Статистика:"
    local total_records=0
    for log in access_*.log; do
        local records=$(wc -l < "$log" 2>/dev/null)
        echo "  $log: $records записей"
        ((total_records += records))
    done
    echo "  Итого: $total_records записей"
}
