# Красная книга Республики Крым — веб-ГИС

Проект представляет собой интерактивную карту ареалов редких растений Крыма с визуализацией на базе Leaflet, данными о растениях и их региональном распространении.

## Технологии

- PHP 8.2 (Backend API)
- PostgreSQL + PostGIS (геоданные)
- Leaflet (картография)
- TailwindCSS (UI)
- Docker / Docker Compose

## Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (с поддержкой Linux-контейнеров)
- Порт **8000** должен быть свободен (можно изменить в `docker-compose.yml`)

## Установка и запуск

### 1. Клонируйте репозиторий

```bash
git clone https://your-repository.git
cd VKR_Krimea_Red_Book
2. Запустите контейнеры
bash
docker compose up --build -d
Первая сборка может занять несколько минут (скачиваются образы PostgreSQL с PostGIS и PHP).

3. Инициализируйте базу данных
Контейнер app автоматически попытается выполнить fix_db.php, но из-за особенностей сетевых настроек рекомендуется вручную прогнать инициализацию:

bash
# Создаём структуру БД и загружаем базовые данные
docker cp ./database/schema.sql redbook_db:/tmp/schema.sql
docker compose exec db psql -U postgres -d redbook_crimea -f /tmp/schema.sql

# Добавляем столбец region_ids в таблицу plants (если отсутствует)
docker compose exec db psql -U postgres -d redbook_crimea -c "ALTER TABLE plants ADD COLUMN IF NOT EXISTS region_ids TEXT[];"

# Запускаем скрипт привязки регионов (заполняет region_ids для всех растений)
docker compose exec -e DB_HOST=db app php fix_db.php
Примечание: Скрипт fix_db.php содержит полный список растений (около 150 видов) и автоматически определяет регионы произрастания на основе ключевых слов в описании.

4. Проверьте работу API
Откройте в браузере:

text
http://localhost:8000/server/api/plants.php?action=list
Вы должны получить JSON-ответ с полями rus_name, lat_name, region_ids, areas_geo и др.

5. Откройте сайт
Главная страница доступна по адресу:

text
http://localhost:8000
Структура проекта
text
.
├── client/                  # Фронтенд (index.html, стили, скрипты)
├── server/                  # PHP API
│   ├── api/
│   │   └── plants.php       # Эндпоинт для получения данных
│   ├── config.php           # Конфигурация БД (через переменные окружения)
│   └── database.php         # Класс для подключения к PostgreSQL
├── database/
│   └── schema.sql           # Полная схема БД + тестовые растения и ареалы
├── docker-compose.yml       # Конфигурация контейнеров
├── Dockerfile               # Образ для PHP/Apache
├── fix_db.php               # Скрипт загрузки и привязки регионов (150+ растений)
└── README.md
Полезные команды
Просмотр логов
docker compose logs -f app или docker compose logs db

Вход в контейнер приложения
docker compose exec app bash

Подключение к PostgreSQL
docker compose exec db psql -U postgres -d redbook_crimea

Остановка контейнеров
docker compose down

Перезапуск только app (после изменения кода)
docker compose restart app

Устранение неполадок
Проблема	Решение
Ошибка 500 Internal Server Error	Проверьте логи: docker compose logs app. Чаще всего проблема в подключении к БД — убедитесь, что в config.php хост указан как db.
На карточке растения «Ареал обитания: Нет данных»	Запустите повторно fix_db.php и пересоздайте представление: docker compose exec db psql -U postgres -d redbook_crimea -c "DROP VIEW v_plants_full; CREATE VIEW ...;" (см. инструкцию выше).
Ошибка relation "plants" does not exist	Вы не выполнили schema.sql. Сделайте это вручную (пункт 3 установки).
Порт 8000 уже занят	Измените порт в docker-compose.yml: "8000:80" → "8080:80", затем docker compose up -d.
Ошибка кодировки invalid byte sequence for encoding "UTF8"	Убедитесь, что файл schema.sql сохранён в UTF-8 без BOM. Пересохраните его в любом редакторе (VS Code, Notepad++).
Настройка переменных окружения
В docker-compose.yml уже заданы параметры подключения для разработки:

yaml
environment:
  DB_HOST: db
  DB_PORT: 5432
  DB_NAME: redbook_crimea
  DB_USER: postgres
  DB_PASSWORD: 29292929
Если вы меняете пароль или имя БД, не забудьте также обновить fix_db.php и database.php.

Запуск GitHub CodeSpace
## Запуск в GitHub Codespaces

Вы можете развернуть проект прямо в браузере с помощью GitHub Codespaces. Это избавит от необходимости устанавливать Docker локально.

### 1. Откройте репозиторий в Codespace

- Перейдите на главную страницу вашего репозитория на GitHub.
- Нажмите кнопку **Code** → вкладка **Codespaces** → **Create codespace on main** (или вашей ветки).

### 2. Дождитесь запуска окружения

После создания Codespace терминал автоматически откроется в корне проекта. Убедитесь, что Docker запущен (обычно он уже работает). При необходимости выполните:

```bash
sudo service docker start   # редко требуется
3. Запустите контейнеры
bash
docker compose up --build -d
4. Инициализируйте базу данных (аналогично локальному запуску)
bash
# Скопируйте и выполните SQL-схему
docker cp ./database/schema.sql redbook_db:/tmp/schema.sql
docker compose exec db psql -U postgres -d redbook_crimea -f /tmp/schema.sql

# Добавьте столбец region_ids (если ещё нет)
docker compose exec db psql -U postgres -d redbook_crimea -c "ALTER TABLE plants ADD COLUMN IF NOT EXISTS region_ids TEXT[];"

# Запустите скрипт привязки регионов
docker compose exec -e DB_HOST=db app php fix_db.php
5. Откройте порт для веб-интерфейса
В Codespaces порт 8000 должен быть автоматически проброшен. Если нет:

Перейдите во вкладку Ports (в терминале или нижней панели VS Code).

Добавьте порт 8000 (если его нет) и убедитесь, что видимость Public (или Private – для личного использования).

Откройте URL вида https://<название-codespace>-8000.preview.app.github.dev или нажмите на значок 🌐 рядом с портом.