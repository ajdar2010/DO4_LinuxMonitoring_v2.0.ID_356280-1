#!/bin/bash


#  записи, отсортированные по коду ответа
handle_option_1() {
    echo " записи, отсортированные по коду ответа"
    awk '{print $9, $0}' $LOG_FILES | sort -n | cut -d' ' -f2-
}

# уникальные IP адреса
handle_option_2() {
    echo " уникальные IP адреса"
    awk '{print $1}' $LOG_FILES | sort -u
}

#запросы с ошибками (4хх или 5хх)
handle_option_3() {
    echo "запросы с ошибками (4xx или 5xx) "
    awk '$9 ~ /^[45][0-9]{2}$/ {print $0}' $LOG_FILES | sort
}

# уникальные IP из ошибочных запросов
handle_option_4() {
    echo "уникальные IP из ошибочных запросов"
    awk '$9 ~ /^[45][0-9]{2}$/ {print $1}' $LOG_FILES | sort -u
}

# диспетчер опций
dispatch_handler() {
    local option=$1
    
    case $option in
        1) handle_option_1 ;;
        2) handle_option_2 ;;
        3) handle_option_3 ;;
        4) handle_option_4 ;;
    esac
}
