FROM php:8.2-apache

# Установка системных зависимостей и расширений PHP
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    git \
    zip \
    unzip \
    && docker-php-ext-install pdo_pgsql pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Включение модуля Apache rewrite (если понадобится в будущем)
RUN a2enmod rewrite

# Установка рабочей директории
WORKDIR /var/www/html

# Копирование файлов проекта
COPY . .

# Настройка прав доступа для Apache
RUN chown -R www-data:www-data /var/www/html

# Открываем порт 80
EXPOSE 80

# Команда запуска (Apache будет служить статические файлы и проксировать PHP)
# Но так как у вас логика на чистом PHP, мы можем использовать встроенный сервер или настроить Apache
# Для простоты оставим Apache, он отлично справляется с PHP файлами
CMD ["apache2-foreground"]