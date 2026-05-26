<?php

// Отключаем вывод ошибок в HTML, чтобы не ломать JSON (ошибки будут в логе PHP)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Логирование ошибок в файл для отладки (если нужно)
// ini_set('log_errors', 1);
// ini_set('error_log', __DIR__ . '/../../php_errors.log');

// Устанавливаем заголовки ДО подключения к БД
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Обработка preflight запроса
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// --- ИСПРАВЛЕНИЕ ПУТИ К БАЗЕ ДАННЫХ ---
// Пробуем несколько вариантов пути, чтобы найти database.php
$dbFile = null;

if (file_exists(__DIR__ . '/../database.php')) {
    $dbFile = __DIR__ . '/../database.php'; // Если database.php в папке server/
} elseif (file_exists(__DIR__ . '/../../database.php')) {
    $dbFile = __DIR__ . '/../../database.php'; // Если database.php в корне проекта
} elseif (file_exists(__DIR__ . '/database.php')) {
    $dbFile = __DIR__ . '/database.php'; // Если вдруг он рядом
}

if ($dbFile) {
    require_once $dbFile;
} else {
    http_response_code(500);
    echo json_encode([
        'error' => 'Файл database.php не найден. Проверьте структуру папок.',
        'searched_paths' => [
            __DIR__ . '/../database.php',
            __DIR__ . '/../../database.php',
            __DIR__ . '/database.php'
        ]
    ]);
    exit;
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Устанавливаем кодировку UTF-8 для PostgreSQL
    $conn->exec("SET NAMES 'UTF8'");
    $conn->exec("SET client_encoding = 'UTF8'");
    
    $action = isset($_GET['action']) ? $_GET['action'] : 'list';

    if ($action === 'list') {
        // Проверяем существование таблицы/представления перед запросом
        $stmt = $conn->query("SELECT * FROM v_plants_full ORDER BY rus_name");
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC), JSON_UNESCAPED_UNICODE);
    } 
    elseif ($action === 'search') {
        $query = isset($_GET['q']) ? trim($_GET['q']) : '';
        if (empty($query)) {
            echo json_encode([], JSON_UNESCAPED_UNICODE);
            exit;
        }
        $sql = "SELECT * FROM v_plants_full 
                WHERE search_vector @@ plainto_tsquery('russian', :query) 
                ORDER BY ts_rank(search_vector, plainto_tsquery('russian', :query)) DESC";
        $stmt = $conn->prepare($sql);
        $stmt->execute(['query' => $query]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC), JSON_UNESCAPED_UNICODE);
    }
    elseif ($action === 'statuses') {
        $stmt = $conn->query("SELECT * FROM cat_status ORDER BY code");
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC), JSON_UNESCAPED_UNICODE);
    }
    else {
        http_response_code(400);
        echo json_encode(['error' => 'Неизвестное действие: ' . $action], JSON_UNESCAPED_UNICODE);
    }

} catch (PDOException $e) {
    http_response_code(500);
    // В продакшене лучше не выводить полное сообщение об ошибке БД
    echo json_encode(['error' => 'Ошибка БД: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Общая ошибка: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
?>