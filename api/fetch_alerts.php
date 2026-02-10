<?php
require_once "db.php";

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

$user_id = (int)($data["user_id"] ?? 0);

if ($user_id <= 0) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "user_id required"]);
    exit;
}

try {
    // If you have alerts table, put your query here.
    $alerts = [];

    echo json_encode([
        "success" => true,
        "alerts" => $alerts
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Server error"]);
}
