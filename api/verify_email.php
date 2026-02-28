<?php
header("Content-Type: application/json; charset=UTF-8");
require_once __DIR__ . "/db.php";

function respond($success, $message, $extra = []) {
  echo json_encode(array_merge([
    "success" => $success,
    "message" => $message
  ], $extra));
  exit;
}

$token = $_GET["token"] ?? "";

if ($token === "") {
  // ✅ always JSON (fixes your Flutter error)
  respond(false, "Invalid token");
}

$stmt = $conn->prepare("
  SELECT user_id FROM users
  WHERE verification_token=? AND email_verified=0
  LIMIT 1
");
$stmt->bind_param("s", $token);
$stmt->execute();
$res = $stmt->get_result();
$row = $res->fetch_assoc();
$stmt->close();

if (!$row) {
  respond(false, "Invalid or expired verification link");
}

$userId = (int)$row["user_id"];

$upd = $conn->prepare("
  UPDATE users
  SET email_verified=1, verification_token=NULL
  WHERE user_id=?
");
$upd->bind_param("i", $userId);
$upd->execute();
$upd->close();

respond(true, "Email verified successfully. You can now login.");