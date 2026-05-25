<?php
// Путь должен вести из папки server/ в server/config.php
require_once 'config.php'; 

class Database {
    private $conn;

    public function __construct() {
        try {
            $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";";
            $this->conn = new PDO($dsn, DB_USER, DB_PASSWORD);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->exec("set names 'utf8'");
            $this->conn->exec("SET NAMES 'UTF8'");
            $this->conn->exec("SET client_encoding TO 'UTF8'");
        } catch (PDOException $e) {
            // Пробрасываем ошибку выше, чтобы её поймал api/plants.php
            throw $e;
        }
    }

    public function getConnection() {
        return $this->conn;
    }
}
?>