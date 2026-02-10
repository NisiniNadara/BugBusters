import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const Color darkGreen = Color(0xFF1A5319);

  final emailController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();

  bool _isLoading = false;

  // Your PHP path: C:\xampp\htdocs\flutter_application_2-main\api
  // Emulator URL:
  final String baseUrl = "http://10.0.2.2/flutter_application_2-main/api";

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isValidEmail(String email) => email.contains("@") && email.contains(".");

  Future<void> _updatePassword() async {
    final email = emailController.text.trim();
    final newPw = newPwController.text.trim();
    final confirmPw = confirmPwController.text.trim();

    if (email.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack("Invalid email");
      return;
    }
    if (newPw.length != 6) {
      _showSnack("New password must be exactly 6 characters");
      return;
    }
    if (newPw != confirmPw) {
      _showSnack("New password and confirm password do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/change_password.php");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "new_password": newPw,
        }),
      );

      // Handle non-JSON server output
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        _showSnack("Server did not return JSON. HTTP ${res.statusCode}");
        return;
      }

      if (res.statusCode == 200 && data["success"] == true) {
        _showSnack("your password has been changed");

        emailController.clear();
        newPwController.clear();
        confirmPwController.clear();

        if (!mounted) return;
        Navigator.pop(context);
      } else {
        _showSnack((data["message"] ?? "Failed").toString());
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    newPwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, color: darkGreen),
                        SizedBox(width: 6),
                        Text("Back",
                            style: TextStyle(color: darkGreen, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Change Password",
              style: TextStyle(
                color: darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Update your password",
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Email instead of current password
                        _textField("Email", emailController, isPassword: false),
                        const SizedBox(height: 10),

                        _textField("New Password (6 characters)", newPwController,
                            isPassword: true),
                        const SizedBox(height: 10),

                        _textField("Confirm New Password", confirmPwController,
                            isPassword: true),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _isLoading ? null : _updatePassword,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    "Update Password",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  Widget _textField(String hint, TextEditingController controller,
      {required bool isPassword}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
