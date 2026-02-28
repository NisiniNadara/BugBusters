<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");

ob_start();
require_once __DIR__ . "/db.php";

function respond($success, $message, $extra = []) {
  if (ob_get_length()) ob_clean();
  echo json_encode(array_merge(["success" => $success, "message" => $message], $extra));
  exit;
}

$user_id = intval(json_decode(file_get_contents("php://input"), true)["user_id"] ?? 0);
if ($user_id <= 0) respond(false, "user_id required");

$sql = "SELECT pump_id, pump_name FROM pump WHERE user_id = ? ORDER BY pump_id DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();

$res = $stmt->get_result();
$pumps = [];

while ($row = $res->fetch_assoc()) {
  $pumps[] = $row;
}

respond(true, "OK", ["pumps" => $pumps]);