<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . "/db.php";

$user_id = intval($_POST["user_id"] ?? 0);
if ($user_id<=0) { echo json_encode(["success"=>false, "message"=>"no user"]); exit; }

$q = $conn->prepare("SELECT id,title,message,severity,created_at FROM alerts WHERE user_id=? ORDER BY created_at DESC");
if (!$q) { http_response_code(500); echo json_encode(["success"=>false,"message"=>"SQL prepare failed (alerts)"]); exit; }
$q->bind_param("i", $user_id);
$q->execute();
$res = $q->get_result();

$alerts = [];
while($row = $res->fetch_assoc()) { $alerts[] = $row; }

echo json_encode(["success"=>true, "alerts"=>$alerts]);
exit;
