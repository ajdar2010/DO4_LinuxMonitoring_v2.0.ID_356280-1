#!/bin/bash

# путь к логам из 4 части
LOGS_PATH="../04/access_*.log"
OUTPUT_FILE="report.html"

#проверяем, установлен ли goaccess
if ! command -v goaccess &> /dev/null; then
    echo "Ошибка: goaccess не установлен. Установите его: sudo apt install goaccess"
    exit 1
fi

# проверка наличия лог-файлов
if ! ls $LOGS_PATH 1> /dev/null 2>&1; then
    echo "Ошибка: Логи в папке ../04/ не найдены. Сначала запусти генератор из Part 4."
    exit 1
fi

echo "Генерация отчета GoAccess из файлов: $LOGS_PATH"

#запуск GoAccess

cat $LOGS_PATH | goaccess - --log-format=COMBINED -a -o $OUTPUT_FILE

if [ $? -eq 0 ]; then
    echo "Отчет создан: $(pwd)/$OUTPUT_FILE"
    echo "Теперь вы можете скачать и открыть этот файл"
else
    echo "Произошла непредвиденная ошибка при генерации отчета."
fi