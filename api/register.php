<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . "/db.php";

$first_name = trim($_POST["first_name"] ?? "");
$last_name  = trim($_POST["last_name"] ?? "");
$email      = strtolower(trim($_POST["email"] ?? ""));
$password   = trim($_POST["password"] ?? "");

/* validations */
if ($first_name === "" || $last_name === "" || $email === "" || $password === "") {
  echo json_encode(["success"=>false, "message"=>"empty fields"]);
  exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  echo json_encode(["success"=>false, "message"=>"invalid email"]);
  exit;
}

/* exactly 6 digits */
if (!preg_match('/^[0-9]{6}$/', $password)) {
  echo json_encode(["success"=>false, "message"=>"password must be 6 digits"]);
  exit;
}

/* duplicate email check */
$check = $conn->prepare("SELECT user_id FROM users WHERE email=?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
  echo json_encode(["success"=>false, "message"=>"duplicate email"]);
  exit;
}

/* generate new user_id (U001, U002...) */
$getMax = $conn->query("SELECT user_id FROM users ORDER BY user_id DESC LIMIT 1");
$nextId = "U001";
if ($getMax && $getMax->num_rows > 0) {
  $row = $getMax->fetch_assoc();
  $num = intval(substr($row["user_id"], 1)) + 1;
  $nextId = "U" . str_pad($num, 3, "0", STR_PAD_LEFT);
}

/* insert (PLAIN PASSWORD) */
$stmt = $conn->prepare(
  "INSERT INTO users (user_id, first_name, last_name, email, password)
   VALUES (?,?,?,?,?)"
);
$stmt->bind_param("sssss", $nextId, $first_name, $last_name, $email, $password);

if ($stmt->execute()) {
  echo json_encode([
    "success" => true,
    "message" => "register success",
    "user_id" => $nextId
  ]);
} else {
  http_response_code(500);
  echo json_encode([
    "success"=>false,
    "message"=>"register failed",
    "sql_error"=>$conn->error
  ]);
}
exit;
