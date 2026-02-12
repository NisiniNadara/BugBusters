<?php
header("Content-Type: application/json; charset=UTF-8");
require_once __DIR__ . "/db.php";

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON input"]);
  exit;
}

$email = trim($data["email"] ?? "");
$password = trim($data["password"] ?? "");

if ($email === "" || $password === "") {
  echo json_encode(["success" => false, "message" => "Missing email or password"]);
  exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  echo json_encode(["success" => false, "message" => "Invalid email"]);
  exit;
}


$stmt = $conn->prepare("SELECT user_id, first_name, last_name, email, telephone, role, password FROM users WHERE email = ? LIMIT 1");
if (!$stmt) {
  echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
  exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();

if (!$res || $res->num_rows === 0) {
  echo json_encode(["success" => false, "message" => "User not found"]);
  exit;
}

$user = $res->fetch_assoc();
$stmt->close();

if ($user["password"] !== $password) {
  echo json_encode(["success" => false, "message" => "Invalid password"]);
  exit;
}


echo json_encode([
  "success" => true,
  "message" => "Login success",
  "user" => [
    "user_id" => (int)$user["user_id"],
    "first_name" => $user["first_name"],
    "last_name" => $user["last_name"],
    "email" => $user["email"],
    "telephone" => $user["telephone"],
    "role" => $user["role"],
  ]
]);
