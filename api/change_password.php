<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");

ob_start();
require_once __DIR__ . "/db.php";

function respond($success, $message, $extra = []) {
  if (ob_get_length()) ob_clean();
  echo json_encode(array_merge(["success" => $success, "message" => $message], $extra));
  exit;
}

set_error_handler(function($severity, $message, $file, $line){
  respond(false, "PHP warning: $message (line $line)");
});

register_shutdown_function(function(){
  $e = error_get_last();
  if ($e && in_array($e["type"], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
    respond(false, "Fatal: {$e["message"]} (line {$e["line"]})");
  }
});

if (!isset($conn) || !($conn instanceof mysqli)) {
  respond(false, "DB connection failed. Check db.php (\$conn)");
}

function getTables(mysqli $conn): array {
  $out = [];
  $res = $conn->query("SHOW TABLES");
  if (!$res) return $out;
  while ($row = $res->fetch_array()) $out[] = $row[0];
  return $out;
}
function getCols(mysqli $conn, string $table): array {
  $cols = [];
  $res = $conn->query("SHOW COLUMNS FROM `$table`");
  if (!$res) return $cols;
  while ($r = $res->fetch_assoc()) $cols[] = $r["Field"];
  return $cols;
}
function pickTable(array $tables, array $cands): ?string {
  foreach ($cands as $c) foreach ($tables as $t) if (strcasecmp($t, $c) === 0) return $t;
  foreach ($cands as $c) {
    $needle = strtolower($c);
    foreach ($tables as $t) if (strpos(strtolower($t), $needle) !== false) return $t;
  }
  return null;
}
function pickCol(array $cols, array $cands): ?string {
  foreach ($cands as $c) foreach ($cols as $col) if (strcasecmp($col, $c) === 0) return $col;
  foreach ($cands as $c) {
    $needle = strtolower($c);
    foreach ($cols as $col) if (strpos(strtolower($col), $needle) !== false) return $col;
  }
  return null;
}

// Read JSON
$raw = file_get_contents("php://input");
if ($raw === false || trim($raw) === "") respond(false, "Empty request body");

$data = json_decode($raw, true);
if (!is_array($data)) respond(false, "Invalid JSON");

$email = trim($data["email"] ?? "");
$newPass = (string)($data["new_password"] ?? "");

if ($email === "" || strpos($email, "@") === false) respond(false, "Valid email required");
if (strlen($newPass) !== 6) respond(false, "New password must be exactly 6 characters");

// Detect users table
$tables = getTables($conn);
$usersTable = pickTable($tables, ["users", "user", "tbl_users", "register", "registration"]);
if ($usersTable === null) respond(false, "Users table not found");

$cols = getCols($conn, $usersTable);
$emailCol = pickCol($cols, ["email", "user_email", "customer_email", "email_address", "mail"]);
$passCol  = "password"; // ✅ as you said

if ($emailCol === null) respond(false, "Email column not found in '$usersTable'");

// Confirm password column exists
$passExists = false;
foreach ($cols as $c) if (strcasecmp($c, $passCol) === 0) $passExists = true;
if (!$passExists) respond(false, "Column 'password' not found in '$usersTable'");

// Check user exists
$check = $conn->prepare("SELECT 1 FROM `$usersTable` WHERE `$emailCol` = ? LIMIT 1");
if (!$check) respond(false, "Prepare failed (check): " . $conn->error);
$check->bind_param("s", $email);
$check->execute();
$r = $check->get_result();
if (!$r || $r->num_rows === 0) {
  $check->close();
  respond(false, "User not found for this email");
}
$check->close();

// Update password (bcrypt hash)
$newHash = password_hash($newPass, PASSWORD_BCRYPT);

$upd = $conn->prepare("UPDATE `$usersTable` SET `$passCol` = ? WHERE `$emailCol` = ? LIMIT 1");
if (!$upd) respond(false, "Prepare failed (update): " . $conn->error);

$upd->bind_param("ss", $newHash, $email);

if (!$upd->execute()) {
  $err = $upd->error ?: $conn->error;
  $upd->close();
  respond(false, "Update failed: " . $err);
}
$upd->close();

respond(true, "Password updated successfully");
