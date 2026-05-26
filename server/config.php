<?php
define('DB_HOST', getenv('DB_HOST') ?: 'db');
define('DB_PORT', getenv('DB_PORT') ?: '5432');
define('DB_NAME', getenv('DB_NAME') ?: 'redbook_crimea');
define('DB_USER', getenv('DB_USER') ?: 'postgres');
define('DB_PASS', getenv('DB_PASSWORD') ?: '29292929');
define('DB_PASSWORD', DB_PASS);
?>