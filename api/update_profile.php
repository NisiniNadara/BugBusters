<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");


ob_start();

require_once __DIR__ . "/db.php";

function respond($success, $message, $extra = []) {
  if (ob_get_length()) { ob_clean(); }
  echo json_encode(array_merge(["success" => $success, "message" => $message], $extra));
  exit;
}


set_error_handler(function ($severity, $message, $file, $line) {
  respond(false, "PHP warning: $message (line $line)");
});


register_shutdown_function(function () {
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


$raw = file_get_contents("php://input");
if ($raw === false || trim($raw) === "") respond(false, "Empty request body");

$data = json_decode($raw, true);
if (!is_array($data)) respond(false, "Invalid JSON");


$user_id   = intval($data["user_id"] ?? 0);
$first     = trim($data["first_name"] ?? "");
$last      = trim($data["last_name"] ?? "");
$email     = trim($data["email"] ?? "");
$role      = trim($data["role"] ?? "");

if ($user_id <= 0) respond(false, "user_id missing. Please login again.");
if ($first === "") respond(false, "first_name required");
if ($email === "" || strpos($email, "@") === false) respond(false, "Valid email required");
if ($role === "") respond(false, "Role required");

// Detect users table
$tables = getTables($conn);
$usersTable = pickTable($tables, ["users", "user", "tbl_users", "register", "registration"]);
if ($usersTable === null) {
  respond(false, "Users table not found. Tried: users/user/tbl_users/register/registration");
}

$cols = getCols($conn, $usersTable);
if (empty($cols)) respond(false, "Cannot read columns from '$usersTable'");

// Detect columns 
$idCol    = pickCol($cols, ["user_id", "id", "uid"]);
$fnCol    = pickCol($cols, ["first_name", "firstname", "fname", "name"]);
$lnCol    = pickCol($cols, ["last_name", "lastname", "lname", "surname"]);
$emailCol = pickCol($cols, ["email", "user_email", "customer_email", "email_address", "mail"]);
$roleCol  = pickCol($cols, ["role", "user_type", "type", "position"]);

if ($idCol === null) respond(false, "User id column not found in '$usersTable' (expected user_id/id/uid)");
if ($emailCol === null) respond(false, "Email column not found in '$usersTable'");
if ($fnCol === null) respond(false, "First name column not found in '$usersTable'");
if ($roleCol === null) respond(false, "Role column not found in '$usersTable'");


$set = [];
$params = [];
$types = "";

$set[] = "`$fnCol` = ?";   $params[] = $first; $types .= "s";

if ($lnCol !== null) {
  $set[] = "`$lnCol` = ?"; $params[] = $last;  $types .= "s";
}

$set[] = "`$emailCol` = ?"; $params[] = $email; $types .= "s";
$set[] = "`$roleCol` = ?";  $params[] = $role;  $types .= "s";

$sql = "UPDATE `$usersTable` SET " . implode(", ", $set) . " WHERE `$idCol` = ? LIMIT 1";
$params[] = $user_id;
$types .= "i";

$stmt = $conn->prepare($sql);
if (!$stmt) respond(false, "Prepare failed: " . $conn->error);

$stmt->bind_param($types, ...$params);

if (!$stmt->execute()) {
  $err = $stmt->error ?: $conn->error;
  $stmt->close();
  respond(false, "Execute failed: " . $err);
}

$affected = $stmt->affected_rows;
$stmt->close();

respond(true, $affected > 0 ? "Profile updated successfully" : "No changes saved");
