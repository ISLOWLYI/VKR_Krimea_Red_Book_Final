<?php
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
     	
     // Если запрос к API - обрабатываем через PHP
    	if (strpos($uri, '/server/api/') === 0) {
     	    $file = __DIR__ . $uri;
         if (file_exists($file) && is_file($file)) {
            require $file;
            return true;
        } else {
            // Файл API не найден - возвращаем 404
            http_response_code(404);
    	        header('Content-Type: application/json');
    	        echo json_encode(['error' => 'API endpoint not found: ' . $uri]);
            return true;
    	    }
    	}
    	
    	// Если запрос к серверным файлам (CSS, JS и т.д.)
    	if (strpos($uri, '/server/') === 0) {
    	    $file = __DIR__ . $uri;
    	    if (file_exists($file) && is_file($file)) {
    	        return false; // Отдаём файл как есть
    	    }
    	}
    	
    	// Статические файлы в корне или других директориях
    	$file = __DIR__ . $uri;
    	if (file_exists($file) && is_file($file)) {
	    return false;
    	}
    	
    	// Для всех остальных случаев (SPA роутинг) -> отдаем index.html
    	if (file_exists(__DIR__ . '/client/index.html')) {
    	    readfile(__DIR__ . '/client/index.html');
    	    return true;
    	}
    	
    	// Если ничего не найдено - 404
    	http_response_code(404);
    	echo '404 Not Found';
    	return true;
    	?>