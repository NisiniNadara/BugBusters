<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');

require_once __DIR__ . "/db.php";

//  Read JSON 
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON input", "alerts" => []]);
  exit;
}

$user_id = intval($data["user_id"] ?? 0);
if ($user_id <= 0) {
  echo json_encode(["success" => false, "message" => "Invalid user_id", "alerts" => []]);
  exit;
}


$sql = "
  SELECT
    a.alert_id,
    a.pump_id,
    p.pump_name,
    a.alert_type,
    a.severity,
    a.message,
    a.alert_date
  FROM alert a
  INNER JOIN pump p ON p.pump_id = a.pump_id
  WHERE p.user_id = ?
  ORDER BY a.alert_date DESC
  LIMIT 200
";

$stmt = $conn->prepare($sql);
if (!$stmt) {
  http_response_code(500);
  echo json_encode(["success" => false, "message" => "SQL prepare failed: " . $conn->error, "alerts" => []]);
  exit;
}

$stmt->bind_param("i", $user_id);

if (!$stmt->execute()) {
  http_response_code(500);
  echo json_encode(["success" => false, "message" => "SQL execute failed: " . $stmt->error, "alerts" => []]);
  exit;
}

$res = $stmt->get_result();

$alerts = [];
while ($row = $res->fetch_assoc()) {
  $alerts[] = [
    "title"      => (string)($row["alert_type"] . " - " . $row["pump_name"]), 
    "severity"   => strtolower((string)$row["severity"]),                    
    "message"    => (string)$row["message"],
    "created_at" => (string)$row["alert_date"],                              
  ];
}

echo json_encode(["success" => true, "alerts" => $alerts]);
exit;
