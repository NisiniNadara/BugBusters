<?php
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . "/../../db.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . "/Exception.php";
require_once __DIR__ . "/PHPMailer.php";
require_once __DIR__ . "/SMTP.php";

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON"]);
  exit;
}

$email = trim($data["email"] ?? "");
if ($email === "" || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
  echo json_encode(["success" => false, "message" => "Invalid email"]);
  exit;
}

if (!isset($conn)) {
  echo json_encode(["success" => false, "message" => "DB connection failed"]);
  exit;
}

$stmt = $conn->prepare("SELECT first_name FROM users WHERE LOWER(TRIM(email)) = LOWER(TRIM(?)) LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
  echo json_encode(["success" => false, "message" => "Email not found"]);
  exit;
}

$row = $res->fetch_assoc();
$firstName = $row["first_name"] ?? "User";
$stmt->close();

$conn->query("
  CREATE TABLE IF NOT EXISTS password_reset_otp (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    otp_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_used TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_email (email),
    KEY idx_expires (expires_at)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
");

$otp = strval(random_int(100000, 999999));
$otpHash = password_hash($otp, PASSWORD_DEFAULT);
$expiresAt = date("Y-m-d H:i:s", time() + 600); // 10 minutes

$upd = $conn->prepare("UPDATE password_reset_otp SET is_used = 1 WHERE email = ? AND is_used = 0");
if ($upd) {
  $upd->bind_param("s", $email);
  $upd->execute();
  $upd->close();
}

$ins = $conn->prepare("INSERT INTO password_reset_otp (email, otp_hash, expires_at, is_used) VALUES (?, ?, ?, 0)");
$ins->bind_param("sss", $email, $otpHash, $expiresAt);
if (!$ins->execute()) {
  echo json_encode(["success" => false, "message" => "DB error: " . $ins->error]);
  exit;
}
$ins->close();

$mail = new PHPMailer(true);

try {
  $mail->isSMTP();
  $mail->Host = "smtp.gmail.com";
  $mail->SMTPAuth = true;

  $mail->Username = "bugbustersapp@gmail.com";
  $mail->Password = "lyjogpdujishxczp"; 
  $mail->SMTPSecure = "tls";
  $mail->Port = 587;

  $mail->setFrom("bugbustersapp@gmail.com", "Bug Busters App");
  $mail->addAddress($email, $firstName);

  $mail->isHTML(false);
  $mail->Subject = "Bug Busters - Password Reset OTP";
  $mail->Body =
    "Hi $firstName,\n\n" .
    "Your OTP code is: $otp\n\n" .
    "This OTP will expire in 10 minutes.\n\n" .
    "Bug Busters Team";

  $mail->send();

  echo json_encode(["success" => true, "message" => "OTP sent successfully"]);
} catch (Exception $e) {
  echo json_encode([
    "success" => false,
    "message" => "Email sending failed",
    "error" => $mail->ErrorInfo
  ]);
}
