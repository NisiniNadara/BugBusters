<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");

ob_start();
require_once __DIR__ . "/db.php";

// PHPMailer
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . "/PHPMailer/src/Exception.php";
require __DIR__ . "/PHPMailer/src/PHPMailer.php";
require __DIR__ . "/PHPMailer/src/SMTP.php";

function respond($success, $message, $extra = []) {
  if (ob_get_length()) ob_clean();
  echo json_encode(array_merge(["success" => $success, "message" => $message], $extra));
  exit;
}

// prevent HTML <br /> errors
set_error_handler(function($severity, $message, $file, $line){
  respond(false, "PHP error: $message (line $line)");
});
register_shutdown_function(function(){
  $e = error_get_last();
  if ($e && in_array($e["type"], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
    respond(false, "Fatal: {$e["message"]} (line {$e["line"]})");
  }
});

if (!isset($conn) || !($conn instanceof mysqli)) {
  respond(false, "DB connection failed. Check db.php");
}

// read JSON body
$raw = file_get_contents("php://input");
if ($raw === false || trim($raw) === "") respond(false, "Empty request body");

$data = json_decode($raw, true);
if (!is_array($data)) respond(false, "Invalid JSON input");

$first = trim($data["first_name"] ?? $data["firstName"] ?? "");
$last  = trim($data["last_name"]  ?? $data["lastName"]  ?? "");
$email = trim($data["email"] ?? "");
$tel   = trim($data["telephone"] ?? $data["phone"] ?? $data["tel"] ?? "");
$role  = trim($data["role"] ?? "");
$pass  = trim($data["password"] ?? "");

if ($first==="" || $last==="" || $email==="" || $role==="" || $pass==="") {
  respond(false, "Missing required fields");
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) respond(false, "Invalid email address");
if (strlen($pass) != 6) respond(false, "Password must be exactly 6 characters");

// email exists?
$check = $conn->prepare("SELECT user_id FROM users WHERE email=? LIMIT 1");
if (!$check) respond(false, "Prepare failed: " . $conn->error);
$check->bind_param("s", $email);
$check->execute();
$check->store_result();
if ($check->num_rows > 0) {
  $check->close();
  respond(false, "Email already registered");
}
$check->close();

// create token
$token = bin2hex(random_bytes(32));
$created = date("Y-m-d");

// insert user (NOT verified)
$stmt = $conn->prepare("
  INSERT INTO users
  (first_name, last_name, email, telephone, role, password, created_date, email_verified, verification_token)
  VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)
");
if (!$stmt) respond(false, "Prepare failed: " . $conn->error);

$stmt->bind_param("ssssssss", $first, $last, $email, $tel, $role, $pass, $created, $token);

if (!$stmt->execute()) {
  $stmt->close();
  respond(false, "Database error: " . $stmt->error);
}
$stmt->close();

// emulator link is OK ONLY for emulator testing
$verifyLink = $verifyLink = $verifyLink = "http://10.40.3.176/flutter_application_2-main/api/verify_email.php?token=$token";

// send mail
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
  $mail->addAddress($email, $first);

  $mail->isHTML(true);
  $mail->Subject = "Verify your Bug Busters account";
  $mail->Body =
    "<p>Hi <b>$first</b>,</p>
     <p>Click the link below to verify your email:</p>
     <p><a href='$verifyLink'>$verifyLink</a></p>
     <p>After verifying, you can login.</p>";

  $mail->send();
} catch (Exception $e) {
  // still JSON
  respond(true, "User created, but email failed to send", ["token" => $token]);
}

respond(true, "Verification email sent. Please verify to login.");