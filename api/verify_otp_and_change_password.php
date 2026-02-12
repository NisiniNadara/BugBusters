<?php
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . "/db.php";

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON"]);
  exit;
}

$email = trim($data["email"] ?? "");
$otp   = trim($data["otp"] ?? "");
$newPw = trim($data["new_password"] ?? "");

if ($email === "" || $otp === "" || $newPw === "") {
  echo json_encode(["success" => false, "message" => "Missing fields"]);
  exit;
}

$stmt = $conn->prepare("
  SELECT id, otp_hash, expires_at, is_used
  FROM password_reset_otp
  WHERE email = ?
  ORDER BY id DESC
  LIMIT 1
");
$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
  echo json_encode(["success" => false, "message" => "OTP not found"]);
  exit;
}

$row = $res->fetch_assoc();
$stmt->close();

if (intval($row["is_used"]) === 1) {
  echo json_encode(["success" => false, "message" => "OTP already used"]);
  exit;
}

if (strtotime($row["expires_at"]) < time()) {
  echo json_encode(["success" => false, "message" => "OTP expired"]);
  exit;
}

if (!password_verify($otp, $row["otp_hash"])) {
  echo json_encode(["success" => false, "message" => "Invalid OTP"]);
  exit;
}

$up = $conn->prepare("UPDATE users SET password = ? WHERE LOWER(TRIM(email)) = LOWER(TRIM(?))");
$up->bind_param("ss", $newPw, $email);
if (!$up->execute()) {
  echo json_encode(["success" => false, "message" => "DB error: " . $up->error]);
  exit;
}
$up->close();

$mark = $conn->prepare("UPDATE password_reset_otp SET is_used = 1 WHERE id = ?");
$otpId = intval($row["id"]);
$mark->bind_param("i", $otpId);
$mark->execute();
$mark->close();

echo json_encode(["success" => true, "message" => "Password updated successfully"]);
