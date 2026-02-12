<?php
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . "/db.php"; // provides $conn

// PHPMailer
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . "/PHPMailer/src/Exception.php";
require __DIR__ . "/PHPMailer/src/PHPMailer.php";
require __DIR__ . "/PHPMailer/src/SMTP.php";

//READ JSON
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON input"]);
  exit;
}

$email = trim($data["email"] ?? "");
$newPw = trim($data["new_password"] ?? "");

//VALIDATION
if ($email === "" || $newPw === "") {
  echo json_encode(["success" => false, "message" => "Missing required fields"]);
  exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  echo json_encode(["success" => false, "message" => "Invalid email address"]);
  exit;
}

if (strlen($newPw) != 6) {
  echo json_encode(["success" => false, "message" => "Password must be exactly 6 characters"]);
  exit;
}

//CHECK USER
$check = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows === 0) {
  echo json_encode(["success" => false, "message" => "Email not found"]);
  exit;
}
$check->close();

//UPDATE PASSWORD
$upd = $conn->prepare("UPDATE users SET password = ? WHERE email = ?");
$upd->bind_param("ss", $newPw, $email);

if (!$upd->execute()) {
  echo json_encode(["success" => false, "message" => "Password update failed"]);
  exit;
}
$upd->close();

//SEND EMAIL
try {
  $mail = new PHPMailer(true);

  $mail->isSMTP();
  $mail->Host = "smtp.gmail.com";
  $mail->SMTPAuth = true;

  $mail->Username = "bugbustersapp@gmail.com";

  $mail->Password = "lyjogpdujishxczp";

  $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
  $mail->Port = 587;

  $mail->setFrom("bugbustersapp@gmail.com", "Bug Busters App");
  $mail->addAddress($email);

  $mail->isHTML(false);
  $mail->Subject = "Bug Busters - Password Changed";
  $mail->Body =
    "Hello,\n\n" .
    "Your Bug Busters account password has been successfully changed.\n\n" .
    "If this was not you, please contact support immediately.\n\n" .
    "Bug Busters Team";

  $mail->send();

} catch (Exception $e) {
}

//SUCCESS 
echo json_encode([
  "success" => true,
  "message" => "Password changed successfully."
]);
