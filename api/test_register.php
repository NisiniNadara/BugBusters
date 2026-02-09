<?php
$_POST["first_name"] = "Test";
$_POST["last_name"]  = "User";
$_POST["email"]      = "testuser" . rand(1000,9999) . "@gmail.com";
$_POST["password"]   = "123456";
include "register.php";
