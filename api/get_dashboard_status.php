<?php
header("Content-Type: application/json; charset=UTF-8");
require_once __DIR__ . "/db.php";

// NEW dummy row each request
$temperature = rand(60, 85);
$vibration   = rand(10, 45) / 10;
$pressure    = rand(30, 60);
$flow_rate   = rand(70, 95);

$conn->query("INSERT INTO dashboard_dummy_data (temperature, vibration, pressure, flow_rate)
              VALUES ($temperature, $vibration, $pressure, $flow_rate)");

// Read the latest row
$sql = "SELECT temperature, vibration, pressure, flow_rate, created_at
        FROM dashboard_dummy_data
        ORDER BY id DESC
        LIMIT 1";

$result = $conn->query($sql);
$row = $result->fetch_assoc();

echo json_encode([
  "success" => true,
  "data" => $row
]);