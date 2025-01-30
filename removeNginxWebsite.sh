#!/bin/sh

# Проверяем, передан ли аргумент с именем сайта
if [ -z "$1" ]; then
    echo "Ошибка: Укажите имя сайта в качестве аргумента."
    echo "Пример использования: $0 example.com"
    exit 1
fi

# Имя сайта (например, example.com), передается как аргумент
SITE_NAME="$1"

# Путь к корневой директории сайта
SITE_ROOT="/var/www/$SITE_NAME"

# Путь к конфигурационному файлу Nginx
NGINX_CONF="/etc/nginx/sites-available/$SITE_NAME"
NGINX_ENABLED_CONF="/etc/nginx/sites-enabled/$SITE_NAME"

# Удаляем конфигурационный файл из sites-available
if [ -f "$NGINX_CONF" ]; then
    sudo rm "$NGINX_CONF"
    echo "Конфигурационный файл $NGINX_CONF удален."
else
    echo "Конфигурационный файл $NGINX_CONF не найден."
fi

# Удаляем символическую ссылку из sites-enabled
if [ -L "$NGINX_ENABLED_CONF" ]; then
    sudo rm "$NGINX_ENABLED_CONF"
    echo "Символическая ссылка $NGINX_ENABLED_CONF удалена."
else
    echo "Символическая ссылка $NGINX_ENABLED_CONF не найдена."
fi

# Удаляем корневую директорию сайта
if [ -d "$SITE_ROOT" ]; then
    sudo rm -rf "$SITE_ROOT"
    echo "Корневая директория сайта $SITE_ROOT удалена."
else
    echo "Корневая директория сайта $SITE_ROOT не найдена."
fi

# Перезагружаем Nginx для применения изменений
sudo nginx -t && sudo systemctl reload nginx
echo "Nginx перезагружен."
