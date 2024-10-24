#!/bin/bash

# Обновление списка пакетов
sudo apt-get update

# Установка Nginx
sudo apt-get install -y nginx

# Копирование файла конфигурации Nginx
sudo cp localhost.conf /etc/nginx/sites-available/localhost.conf

# Создание ссылки
sudo ln -s /etc/nginx/sites-available/localhost.conf /etc/nginx/sites-enabled/localhost.conf

# Перезапуск и включение Nginx в качестве службы
sudo systemctl restart nginx
sudo systemctl enable nginx

# Проверка наличия Composer
if ! command -v composer &> /dev/null
then
    # Установка Composer
    echo "Composer not found. Installing now..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    echo "Composer installed."
else
    echo "Composer already installed."
fi

# Установка php
PHP_VERSION="8.2"
sudo add-apt-repository ppa:ondrej/php
sudo apt-get install -y php$PHP_VERSION-fpm php$PHP_VERSION-mbstring php$PHP_VERSION-bcmath php$PHP_VERSION-xml php$PHP_VERSION-mysql php$PHP_VERSION-sqlite3 php$PHP_VERSION-common php$PHP_VERSION-gd php$PHP_VERSION-bz2 php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-curl php$PHP_VERSION-zip php$PHP_VERSION-gd php$PHP_VERSION-curl php$PHP_VERSION-xdebug php$PHP_VERSION-intl 

# Включение вывода ошибок
PHP_INI="/etc/php/$PHP_VERSION/fpm/php.ini"

sudo sed -i 's/^display_errors = .*/display_errors = On/' "$PHP_INI"
sudo sed -i 's/^display_startup_errors = .*/display_startup_errors = On/' "$PHP_INI"
sudo sed -i 's/^error_reporting = .*/error_reporting = E_ALL/' "$PHP_INI"

# Установка Xdebug
XDEBUG_INI="/etc/php/$PHP_VERSION/mods-available/xdebug.ini"

echo "zend_extension=xdebug.so" | sudo tee "$XDEBUG_INI"
echo "xdebug.mode=debug" | sudo tee -a "$XDEBUG_INI"
echo "xdebug.start_with_request=yes" | sudo tee -a "$XDEBUG_INI"
echo "xdebug.client_port=9003" | sudo tee -a "$XDEBUG_INI"
echo "xdebug.client_host=127.0.0.1" | sudo tee -a "$XDEBUG_INI"

# Перезапуск PHP-сервера
sudo systemctl restart php$PHP_VERSION-fpm

# Установка git
sudo apt-get install -y git

# Установко node.js
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install node