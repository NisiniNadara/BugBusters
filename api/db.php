<?php
// db.php
// ✅ Database: bug_busters_app

$DB_HOST = "localhost";
$DB_USER = "root";
$DB_PASS = "";               // XAMPP default = empty
$DB_NAME = "bug_busters_app";

$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);

if ($conn->connect_error) {
  header("Content-Type: application/json; charset=UTF-8");
  echo json_encode([
    "success" => false,
    "message" => "DB connection failed: " . $conn->connect_error
  ]);
  exit;
}

$conn->set_charset("utf8mb4");
