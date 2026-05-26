
# Политика безопасности

## Уязвимости и исправления в версии 1.0.1

### SQL-инъекции (ИСПРАВЛЕНО)
**Проблема**: В оригинальном коде поисковый запрос напрямую подставлялся в SQL с использованием `ILIKE`, что позволяло выполнять SQL-инъекции через специальные символы (`%`, `_`, `\`).

**Решение**:
- Добавлено экранирование через `pg_escape_string()`
- Реализована очистка спецсимволов для tsquery
- Используется гибридный поиск с параметризованными запросами

```php
// Было (уязвимо):
$stmt->execute(['query' => '%' . $query . '%']);

// Стало (безопасно):
$escapedQuery = pg_escape_string($query);
$stmt->execute([
    'query' => str_replace(['%', '_', '\\'], ['', '', ''], $escapedQuery),
    'like_query' => '%' . $escapedQuery . '%'
]);
```

### XSS атаки (ЗАЩИЩЕНО)
**Меры защиты**:
- Все данные из БД выводятся через `htmlspecialchars()` в контексте HTML
- Leaflet автоматически экранирует содержимое popup
- Content-Type заголовки установлены явно

### CORS (НАСТРОЕНО)
**Файл**: `server/.htaccess`
- Явно указаны разрешённые методы: GET, POST, OPTIONS
- Обработка preflight запросов
- Заголовок Access-Control-Allow-Headers для Content-Type

## Рекомендации по развёртыванию

### Обязательные действия
1. **Измените пароль БД** в `server/config.php`
2. **Настройте HTTPS** на продакшене
3. **Ограничьте доступ** к директории `server/` только для API запросов
4. **Включите логирование** ошибок PHP

### Рекомендуемые настройки PostgreSQL
```sql
-- Ограничить права пользователя БД
CREATE USER redbook_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE redbook_crimea TO redbook_user;
GRANT USAGE ON SCHEMA public TO redbook_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO redbook_user;
-- Не давать INSERT/UPDATE/DELETE для read-only API
```

### Настройки PHP
```ini
display_errors = Off
log_errors = On
error_log = /var/log/php/redbook.log
expose_php = Off
allow_url_fopen = Off
```

## Сообщение об уязвимостях

При обнаружении уязвимостей просим сообщать автору проекта.

