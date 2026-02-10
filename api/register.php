<?php
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . "/db.php"; // ✅ provides $conn

// ---------- PHPMailer ----------
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . "/PHPMailer/src/Exception.php";
require __DIR__ . "/PHPMailer/src/PHPMailer.php";
require __DIR__ . "/PHPMailer/src/SMTP.php";

// ---------- READ JSON ----------
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  echo json_encode(["success" => false, "message" => "Invalid JSON input"]);
  exit;
}

// ---------- ACCEPT BOTH key styles ----------
$first = trim($data["first_name"] ?? $data["firstName"] ?? "");
$last  = trim($data["last_name"]  ?? $data["lastName"]  ?? "");
$email = trim($data["email"] ?? "");
$tel   = trim($data["telephone"] ?? $data["phone"] ?? $data["tel"] ?? "");
$role  = trim($data["role"] ?? "");
$pass  = trim($data["password"] ?? "");

// ---------- VALIDATION ----------
if ($first === "" || $last === "" || $email === "" || $role === "" || $pass === "") {
  echo json_encode(["success" => false, "message" => "Missing required fields"]);
  exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  echo json_encode(["success" => false, "message" => "Invalid email address"]);
  exit;
}

if (strlen($pass) != 6) {
  echo json_encode(["success" => false, "message" => "Password must be exactly 6 characters"]);
  exit;
}

// ---------- CHECK DB CONNECTION ----------
if (!isset($conn) || $conn === null) {
  echo json_encode(["success" => false, "message" => "DB connection is null. Check db.php"]);
  exit;
}

// ---------- CHECK EMAIL EXISTS ----------
$check = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
if (!$check) {
  echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
  exit;
}
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
  echo json_encode(["success" => false, "message" => "Email already registered"]);
  exit;
}
$check->close();

// ---------- INSERT USER ----------
$created = date("Y-m-d");

$stmt = $conn->prepare("
  INSERT INTO users (first_name, last_name, email, telephone, role, password, created_date)
  VALUES (?, ?, ?, ?, ?, ?, ?)
");
if (!$stmt) {
  echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
  exit;
}

$stmt->bind_param("sssssss", $first, $last, $email, $tel, $role, $pass, $created);

if (!$stmt->execute()) {
  echo json_encode(["success" => false, "message" => "Database error: " . $stmt->error]);
  exit;
}
$stmt->close();

// ---------- SEND EMAIL (does NOT block success) ----------
try {
  $mail = new PHPMailer(true);

  $mail->isSMTP();
  $mail->Host = "smtp.gmail.com";
  $mail->SMTPAuth = true;

  // ✅ your gmail
  $mail->Username = "bugbustersapp@gmail.com";

  // ✅ app password (NO SPACES)
  $mail->Password = "lyjogpdujishxczp";

  $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
  $mail->Port = 587;

  $mail->setFrom("bugbustersapp@gmail.com", "Bug Busters App");
  $mail->addAddress($email, $first);

  $mail->isHTML(false);
  $mail->Subject = "Bug Busters - Registration Successful";
  $mail->Body =
    "Hi $first,\n\n" .
    "You have successfully registered the Bug Busters app.\n\n" .
    "Bug Busters Team";

  $mail->send();
} catch (Exception $e) {
  // ignore email errors so app still works
}

// ---------- SUCCESS ----------
echo json_encode([
  "success" => true,
  "message" => "Registration successful. Confirmation email sent."
]);
