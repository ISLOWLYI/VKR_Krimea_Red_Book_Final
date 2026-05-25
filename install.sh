#!/bin/bash

# Скрипт установки веб-ГИС "Красная книга Республики Крым"
# Требования: PostgreSQL с PostGIS, PHP 7.4+

set -e

echo "=========================================="
echo "Установка веб-ГИС Красная книга Крыма"
echo "=========================================="

# Конфигурация
DB_NAME="redbook_crimea"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

echo ""
echo "Шаг 1: Проверка требований..."

# Проверка PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL не найден. Установите PostgreSQL."
    exit 1
fi
echo "✓ PostgreSQL найден"

# Проверка PostGIS
if ! psql -U $DB_USER -c "SELECT postgis_version();" &> /dev/null; then
    echo "⚠️  PostGIS не установлен или недоступен"
fi

echo ""
echo "Шаг 2: Создание базы данных..."

# Создать базу данных
if psql -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo "⚠️  База данных $DB_NAME уже существует"
    read -p "Удалить существующую базу данных? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        dropdb -U $DB_USER $DB_NAME
        echo "✓ База данных удалена"
    else
        echo "✗ Пропущено создание базы данных"
        exit 1
    fi
fi

createdb -U $DB_USER $DB_NAME
echo "✓ База данных создана"

echo ""
echo "Шаг 3: Включение расширения PostGIS..."

psql -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS postgis;"
echo "✓ PostGIS включён"

echo ""
echo "Шаг 4: Создание структуры БД и загрузка данных..."

psql -U $DB_USER -d $DB_NAME -f database/schema.sql
echo "✓ Структура БД создана, данные загружены"

echo ""
echo "Шаг 5: Настройка конфигурации..."

# Предложить изменить пароль
read -p "Изменить пароль БД в config.php? (y/N): " change_pwd
if [[ $change_pwd == [yY] ]]; then
    read -sp "Введите новый пароль: " new_password
    echo ""
    sed -i "s/define('DB_PASSWORD', 'postgres')/define('DB_PASSWORD', '$new_password')/" server/config.php
    echo "✓ Пароль обновлён"
fi

echo ""
echo "=========================================="
echo "✓ Установка завершена успешно!"
echo ""
echo "Для запуска используйте:"
echo "  php -S localhost:8000"
echo ""
echo "Откройте в браузере: http://localhost:8000/client/"
echo "=========================================="