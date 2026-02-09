<?php
header('Content-Type: application/json; charset=utf-8');

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "bug_busters_app"; // ✅ your real DB name

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["success"=>false, "message"=>"DB connection failed"]);
  exit;
}
?>
