<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . "/db.php";

$user_id = intval($_POST["user_id"] ?? 0);
$device_name = trim($_POST["device_name"] ?? "");
$device_code = trim($_POST["device_code"] ?? "");

if ($user_id<=0 || $device_name==="" || $device_code==="") {
  echo json_encode(["success"=>false, "message"=>"empty fields"]); exit;
}

$stmt = $conn->prepare("INSERT INTO devices(user_id,device_name,device_code) VALUES(?,?,?)");
if (!$stmt) { http_response_code(500); echo json_encode(["success"=>false,"message"=>"SQL prepare failed (devices)"]); exit; }
$stmt->bind_param("iss", $user_id, $device_name, $device_code);

if ($stmt->execute()) {
  echo json_encode(["success"=>true, "message"=>"device added"]);
} else {
  http_response_code(500);
  echo json_encode(["success"=>false, "message"=>"device add failed"]);
}
exit;
