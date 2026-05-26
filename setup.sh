#!/bin/bash
# setup.sh - Запуск проекта через Docker

set -e

echo "=========================================="
echo "🐳 Запуск проекта через Docker"
echo "=========================================="

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден. Пожалуйста, установите Docker Desktop."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose не найден."
    exit 1
fi

# Определение команды docker compose (новая версия или старая)
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="docker-compose"
fi

echo "🚀 Сборка и запуск контейнеров..."
$DOCKER_COMPOSE_CMD up --build -d

echo ""
echo "⏳ Ожидание инициализации базы данных и заполнения данными..."
sleep 10

# Проверка логов на наличие ошибок при инициализации
echo "📋 Последние логи инициализации:"
$DOCKER_COMPOSE_CMD logs app | tail -n 20

echo ""
echo "=========================================="
echo "✅ Проект запущен!"
echo "=========================================="
echo ""
echo "🌐 Откройте в браузере: http://localhost:8000"
echo ""
echo "Полезные команды:"
echo "  Просмотр логов:       $DOCKER_COMPOSE_CMD logs -f"
echo "  Остановка:            $DOCKER_COMPOSE_CMD down"
echo "  Перезапуск:           $DOCKER_COMPOSE_CMD restart"
echo "  Вход в контейнер APP: $DOCKER_COMPOSE_CMD exec app bash"
echo "  Вход в контейнер DB:  $DOCKER_COMPOSE_CMD exec db psql -U postgres"