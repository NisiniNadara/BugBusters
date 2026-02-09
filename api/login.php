<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . "/db.php";

$email    = strtolower(trim($_POST["email"] ?? ""));
$password = trim($_POST["password"] ?? "");

if ($email === "" || $password === "") {
  echo json_encode(["success"=>false, "message"=>"empty fields"]);
  exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  echo json_encode(["success"=>false, "message"=>"invalid email"]);
  exit;
}

$stmt = $conn->prepare(
  "SELECT user_id, password FROM users WHERE email=? LIMIT 1"
);
$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();

if ($row = $res->fetch_assoc()) {
  if ($password === $row["password"]) {
    echo json_encode([
      "success" => true,
      "message" => "login success",
      "user_id" => $row["user_id"]
    ]);
  } else {
    echo json_encode(["success"=>false, "message"=>"wrong password"]);
  }
} else {
  echo json_encode(["success"=>false, "message"=>"user not found"]);
}
exit;
