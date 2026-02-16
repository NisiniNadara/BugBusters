import 'dart:convert';
import 'package:flutter/material.dart';
import 'second_page.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const Color darkGreen = Color(0xFF1A5319);

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();

  bool _sendingOtp = false;
  bool _updatingPw = false;

  
  static const String baseUrl =
      "http://192.168.109.136/flutter_application_2-main/api";

  
  static const String sendOtpUrl = "$baseUrl/PHPMailer/src/send_reset_otp.php";
  static const String changePwUrl =
      "$baseUrl/verify_otp_and_change_password.php";

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isValidEmail(String email) => email.contains("@") && email.contains(".");

  Future<Map<String, dynamic>> _postJson(String url, Map body) async {
    final res = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode(body),
    );

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        decoded["_httpStatus"] = res.statusCode;
        return decoded;
      }
      return {
        "success": false,
        "message": "Invalid JSON format",
        "_httpStatus": res.statusCode
      };
    } catch (_) {
      return {
        "success": false,
        "message":
            "Server did not return JSON. HTTP ${res.statusCode}\nURL: $url\nBody: ${res.body}",
        "_httpStatus": res.statusCode
      };
    }
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (!_isValidEmail(email)) {
      _showSnack("Enter a valid email");
      return;
    }

    setState(() => _sendingOtp = true);

    final data = await _postJson(sendOtpUrl, {"email": email});

    if (!mounted) return;
    setState(() => _sendingOtp = false);

    _showSnack(data["message"]?.toString() ?? "Done");
  }

  Future<void> updatePassword() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPw = newPwController.text.trim();
    final confirm = confirmPwController.text.trim();

    if (!_isValidEmail(email)) {
      _showSnack("Enter a valid email");
      return;
    }
    if (otp.length != 6) {
      _showSnack("OTP must be 6 digits");
      return;
    }
    if (newPw.length != 6) {
      _showSnack("Password must be exactly 6 characters");
      return;
    }
    if (newPw != confirm) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => _updatingPw = true);

    final data = await _postJson(changePwUrl, {
      "email": email,
      "otp": otp,
      "new_password": newPw,
    });

    if (!mounted) return;
    setState(() => _updatingPw = false);

    final ok = data["success"] == true;
    _showSnack(data["message"]?.toString() ?? "Done");

    if (ok) {
      otpController.clear();
      newPwController.clear();
      confirmPwController.clear();

      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SecondPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendEnabled = !_sendingOtp;
    final updateEnabled = !_updatingPw;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Back", style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Change Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 16,
                      color: Color(0x22000000),
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update your password",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: sendEnabled ? sendOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          _sendingOtp ? "Sending..." : "Send Verification Code",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: "OTP Code (6 digits)",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPwController,
                      obscureText: true,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: "New Password (6 characters)",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPwController,
                      obscureText: true,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: "Confirm New Password",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updateEnabled ? updatePassword : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          _updatingPw ? "Updating..." : "Update Password",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
