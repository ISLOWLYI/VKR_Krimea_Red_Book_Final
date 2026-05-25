<?php
// router.php - перенаправляет запросы на client/index.html

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Если запрос к корню или несуществующему файлу -> отдаем index.html
if ($uri === '/' || $uri === '' || !file_exists(__DIR__ . $uri)) {
    // Проверяем, существует ли index.html в папке client
    if (file_exists(__DIR__ . '/client/index.html')) {
        require __DIR__ . '/client/index.html';
        return true;
    }
}

// Для всех остальных файлов (css, js, api) пытаемся отдать их как есть
// Если файл не найден, вернется стандартная 404 от PHP
return false;
?>