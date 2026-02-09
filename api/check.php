<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include "db.php";

$result = $conn->query("SHOW TABLES");
$tables = [];

if ($result && $result->num_rows > 0) {
  while ($row = $result->fetch_array()) {
    $tables[] = $row[0];
  }
}

echo json_encode([
  "success" => true,
  "tables" => $tables
]);
exit;
?>
$email = $_POST['email'];
$password = $_POST['password'];

// check from database
echo "ok";

