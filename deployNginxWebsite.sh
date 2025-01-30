#!/bin/bash

# Проверка, что передана папка с сайтом
if [ -z "$1" ]; then
  echo "Использование: $0 <папка_с_сайтом>"
  exit 1
fi

# Переменные
SITE_DIR=$1
SITE_NAME=$(basename "$SITE_DIR")
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_CONF_LINK_DIR="/etc/nginx/sites-enabled"
WEB_ROOT="/var/www/$SITE_NAME"

# Проверка, существует ли папка с сайтом
if [ ! -d "$SITE_DIR" ]; then
  echo "Папки $SITE_DIR не существует."
  exit 1
fi

# Перемещение папки с сайтом в /var/www
echo "Перемещение папки с сайтом в /var/www..."
sudo mv "$SITE_DIR" "$WEB_ROOT"

# Создание Nginx конфига
echo "Создание Nginx конфига..."
sudo bash -c "cat > $NGINX_CONF_DIR/$SITE_NAME <<EOF
server {
    listen 80;
    server_name $SITE_NAME;

    root $WEB_ROOT;
    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF"

# Создание символической ссылки на конфиг в sites-enabled
echo "Создание символической ссылки на конфиг..."
sudo ln -s "$NGINX_CONF_DIR/$SITE_NAME" "$NGINX_CONF_LINK_DIR/$SITE_NAME"

# Проверка конфигурации Nginx
echo "Проверка конфигурации Nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
  # Перезапуск Nginx
  echo "Перезапуск Nginx..."
  sudo systemctl restart nginx
  echo "Сайт $SITE_NAME успешно развернут и доступен по адресу http://$SITE_NAME"
else
  echo "Ошибка в конфигурации Nginx. Пожалуйста, проверьте конфигурацию вручную."
fi
