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

set_error_handler(function($severity, $message, $file, $line){
  respond(false, "PHP warning: $message (line $line)");
});

register_shutdown_function(function(){
  $e = error_get_last();
  if ($e && in_array($e["type"], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
    respond(false, "Fatal: {$e["message"]} (line {$e["line"]})");
  }
});

if (!isset($conn) || !($conn instanceof mysqli)) respond(false, "DB connection failed. Check db.php");

$raw = file_get_contents("php://input");
if ($raw === false || trim($raw) === "") respond(false, "Empty request body");

$data = json_decode($raw, true);
if (!is_array($data)) respond(false, "Invalid JSON");

$user_id = intval($data["user_id"] ?? 0);
$pump_name = trim($data["pump_name"] ?? "");
$location = trim($data["pump_location"] ?? "");
if ($location === "") $location = trim($data["location"] ?? "");

if ($user_id <= 0) respond(false, "user_id required");
if ($pump_name === "" || $location === "") respond(false, "pump_name and location required");

// Duplicate check (same user cannot use same pump_name)
$checkSql = "SELECT 1 FROM pump WHERE user_id = ? AND pump_name = ? LIMIT 1";
$checkStmt = $conn->prepare($checkSql);
if (!$checkStmt) respond(false, "Prepare failed (check): " . $conn->error);

$checkStmt->bind_param("is", $user_id, $pump_name);
$checkStmt->execute();
$checkRes = $checkStmt->get_result();

if ($checkRes && $checkRes->num_rows > 0) {
  $checkStmt->close();
  respond(false, "This Device Name already exists for your account. Please use a different name.");
}
$checkStmt->close();

// Insert
$insSql = "INSERT INTO pump (user_id, pump_name, location) VALUES (?, ?, ?)";
$insStmt = $conn->prepare($insSql);
if (!$insStmt) respond(false, "Prepare failed (insert): " . $conn->error);

$insStmt->bind_param("iss", $user_id, $pump_name, $location);

if ($insStmt->execute()) {
  respond(true, "Device added successfully", ["pump_id" => $conn->insert_id]);
} else {
  respond(false, "Insert failed: " . $conn->error);
}
