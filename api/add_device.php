<?php
require_once "db.php";

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

$user_name   = trim($data["user_name"] ?? "");
$device_name = trim($data["device_name"] ?? "");
$device_id   = trim($data["device_id"] ?? "");

if ($user_name === "" || $device_name === "" || $device_id === "") {
  echo json_encode(["success" => false, "message" => "Missing fields"]);
  exit();
}

// Create table fields accordingly (see SQL below)
$stmt = $conn->prepare("INSERT INTO devices (user_name, device_name, device_id) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $user_name, $device_name, $device_id);

if ($stmt->execute()) {
  echo json_encode(["success" => true, "message" => "Device added"]);
} else {
  // Duplicate device_id (unique constraint)
  if ($conn->errno == 1062) {
    echo json_encode(["success" => false, "message" => "Device already added"]);
  } else {
    echo json_encode(["success" => false, "message" => "Insert failed"]);
  }
}
$stmt->close();
$conn->close();
?>
