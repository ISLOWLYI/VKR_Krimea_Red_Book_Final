<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once '../database.php';

$db = new Database();
$conn = $db->getConnection();

// 3. Явно указываем PostgreSQL работать в UTF-8
// Эта строка критически важна!
$conn->exec("SET NAMES 'UTF8'"); 
$conn->exec("SET client_encoding = 'UTF8'");

// Включаем отображение ошибок для отладки (в продакшене выключить!)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Заголовки для CORS и JSON
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Функция для возврата JSON ошибки
function sendError($message) {
    http_response_code(500);
    echo json_encode(['error' => $message]);
    exit;
}

// Проверка существования файла конфигурации
if (!file_exists('../database.php')) {
    sendError('Файл database.php не найден по пути ../database.php. Текущая папка: ' . __DIR__);
}

try {
    require_once '../database.php';
    
    $db = new Database();
    $conn = $db->getConnection();

    $action = isset($_GET['action']) ? $_GET['action'] : 'list';

    if ($action === 'list') {
        $stmt = $conn->query("SELECT * FROM v_plants_full ORDER BY rus_name");
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    } 
    elseif ($action === 'search') {
        $query = isset($_GET['q']) ? trim($_GET['q']) : '';
        if (empty($query)) {
            echo json_encode([]);
            exit;
        }
        $sql = "SELECT * FROM v_plants_full 
                WHERE search_vector @@ plainto_tsquery('russian', :query) 
                ORDER BY ts_rank(search_vector, plainto_tsquery('russian', :query)) DESC";
        $stmt = $conn->prepare($sql);
        $stmt->execute(['query' => $query]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }
    elseif ($action === 'statuses') {
        $stmt = $conn->query("SELECT * FROM cat_status ORDER BY code");
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }
    else {
        sendError('Неизвестное действие: ' . $action);
    }

} catch (PDOException $e) {
    // Ловим ошибки базы данных и выводим их в JSON
    sendError('Ошибка БД: ' . $e->getMessage());
} catch (Exception $e) {
    // Ловим остальные ошибки
    sendError('Общая ошибка: ' . $e->getMessage());
}
?>