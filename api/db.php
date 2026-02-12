<?php

$host = "localhost";
$user = "root";
$pass = "";
$db   = "bug_busters_app";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
  http_response_code(500);
  header("Content-Type: application/json; charset=UTF-8");
  echo json_encode(["success" => false, "message" => "DB connection failed"]);
  exit;
}

$conn->set_charset("utf8mb4");
