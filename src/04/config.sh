#!/bin/bash

readonly -a HTTP_CODES=(200 201 400 401 403 404 500 501 502 503)

# HTTP методы
readonly -a HTTP_METHODS=(GET POST PUT PATCH DELETE)

# User-Agent строки (разные браузеры и боты)
readonly -a AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15"
    "Opera/9.80 (X11; Linux x86_64) Presto/2.12.388"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/537.36"
    "Mozilla/4.0 (compatible; MSIE 9.0; Windows NT 6.1)"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/91.0.864.59"
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    "curl/7.68.0"
    "wget/1.20.3"
)

# URLs для запросов
readonly -a URLS=(
    "/index.html"
    "/api/users"
    "/api/products"
    "/api/orders"
    "/admin/dashboard"
    "/static/css/style.css"
    "/static/js/main.js"
    "/login"
    "/logout"
    "/register"
    "/search?q=test"
    "/products/123"
    "/users/456/profile"
    "/api/v1/data"
)

# Параметры генерации
readonly START_DATE="2026-03-01"
readonly DAYS_COUNT=5
readonly MIN_ENTRIES=100
readonly MAX_ENTRIES=1000
readonly MIN_RESPONSE_SIZE=100
readonly MAX_RESPONSE_SIZE=50000
