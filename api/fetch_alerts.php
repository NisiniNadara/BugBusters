<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . "/db.php";

// Flutter sends JSON
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON input", "alerts" => []]);
  exit;
}

$user_id = intval($data["user_id"] ?? 0);
if ($user_id <= 0) {
  echo json_encode(["success" => false, "message" => "no user", "alerts" => []]);
  exit;
}

/*
Schema:
users(user_id) -> pump(user_id) -> pump_status(pump_id)

We use pump_status as "alerts"
*/
$sql = "
  SELECT
    ps.status_id,
    ps.pump_id,
    p.pump_name,
    ps.status,
    ps.update_date
  FROM pump_status ps
  INNER JOIN pump p ON p.pump_id = ps.pump_id
  WHERE p.user_id = ?
  ORDER BY ps.update_date DESC
  LIMIT 200
";

$q = $conn->prepare($sql);
if (!$q) {
  http_response_code(500);
  echo json_encode(["success" => false, "message" => "SQL prepare failed (pump_status alerts)", "alerts" => []]);
  exit;
}

$q->bind_param("i", $user_id);
$q->execute();
$res = $q->get_result();

$alerts = [];
while ($row = $res->fetch_assoc()) {
  $status = strtolower((string)$row["status"]);

  // ✅ severity rule (edit if you want)
  $severity = "low";
  if (strpos($status, "fail") !== false || strpos($status, "error") !== false || strpos($status, "offline") !== false) {
    $severity = "high";
  } elseif (strpos($status, "warn") !== false || strpos($status, "abnormal") !== false) {
    $severity = "medium";
  }

  $alerts[] = [
    "id"         => (string)$row["status_id"],
    "pump_id"    => (string)$row["pump_id"],
    "title"      => "Pump " . (string)$row["pump_name"],
    "message"    => "Status: " . (string)$row["status"],
    "severity"   => (string)$severity,
    "created_at" => (string)$row["update_date"],
  ];
}

echo json_encode(["success" => true, "alerts" => $alerts]);
exit;
