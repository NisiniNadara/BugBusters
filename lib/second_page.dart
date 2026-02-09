import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sign_up_page.dart';
import 'add_device_page.dart';
import 'api_service.dart';

// ✅ ADD THIS IMPORT (your settings page)
import 'settings_page.dart';

class SecondPage extends StatefulWidget {
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => email.contains("@") && email.contains(".");

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _msg("empty fields");
      return;
    }
    if (!_isValidEmail(email)) {
      _msg("invalid email");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.login(email: email, password: password);

      if (result["success"] == true) {
        final sp = await SharedPreferences.getInstance();
        await sp.setString("user_id", result["user_id"].toString());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddDevicePage()),
        );
      } else {
        _msg(result["message"].toString());
      }
    } catch (e) {
      _msg("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ Forgot password action
  void _openForgotPassword() {
    // If your Settings page has "Change Password" inside it,
    // open Settings page and user can change password there.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );

    // If you have a separate change password page like ChangePasswordPage(),
    // tell me the file name and I will change this route.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'BUG BUSTERS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(child: Container()),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF1A5319),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '     User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ✅ SAME UI TEXT, just made clickable
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: _openForgotPassword,
                      child: Text(
                        'forget password?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        "Don't have any account? Sign Up",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
}
