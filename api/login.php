<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");

require_once __DIR__ . "/db.php";

function respond($success, $message, $extra = []) {
  echo json_encode(array_merge([
    "success" => $success,
    "message" => $message
  ], $extra));
  exit;
}

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) respond(false, "Invalid JSON");

$email = trim($data["email"] ?? "");
$pass  = trim($data["password"] ?? "");

if ($email === "" || $pass === "") {
  respond(false, "Email and password required");
}

$stmt = $conn->prepare("
  SELECT user_id, first_name, last_name, email, telephone, role, password, email_verified
  FROM users
  WHERE email = ?
  LIMIT 1
");
if (!$stmt) respond(false, "Prepare failed: " . $conn->error);

$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();
$user = $res->fetch_assoc();
$stmt->close();

if (!$user) {
  respond(false, "Invalid email or password");
}

// password check (your DB stores plain text currently)
if ($user["password"] !== $pass) {
  respond(false, "Invalid email or password");
}

// ✅ block login if not verified
if ((int)$user["email_verified"] !== 1) {
  respond(false, "Please verify your email first");
}

// ✅ SUCCESS + send ALL needed user data
respond(true, "Login success", [
  "user" => [
    "user_id" => (int)$user["user_id"],
    "first_name" => $user["first_name"],
    "last_name" => $user["last_name"],
    "email" => $user["email"],
    "telephone" => $user["telephone"],
    "role" => $user["role"],
  ]
]);