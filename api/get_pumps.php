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

if (!isset($conn) || !($conn instanceof mysqli)) {
  respond(false, "DB connection failed. Check db.php (\$conn)");
}

$raw = file_get_contents("php://input");
if ($raw === false || trim($raw) === "") respond(false, "Empty request body");

$data = json_decode($raw, true);
if (!is_array($data)) respond(false, "Invalid JSON");

$user_id = intval($data["user_id"] ?? 0);
if ($user_id <= 0) respond(false, "user_id required");

$table = "pump";

// pump table details
$sql = "SELECT pump_id, pump_name FROM `$table` WHERE user_id = ? ORDER BY pump_id DESC";
$stmt = $conn->prepare($sql);
if (!$stmt) respond(false, "Prepare failed: " . $conn->error);

$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();

$pumps = [];
while ($row = $res->fetch_assoc()) {
  $pumps[] = [
    "pump_id" => $row["pump_id"],
    "pump_name" => $row["pump_name"],
  ];
}
$stmt->close();

respond(true, "OK", ["pumps" => $pumps]);
