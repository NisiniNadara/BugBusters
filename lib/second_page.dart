import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ ADD THIS import (no UI change)
import 'auth/auth_service.dart';

import 'app_lang.dart';
import 'change_password_page.dart';
import 'sign_up_page.dart';
import 'add_device_page.dart';
import 'api_service.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

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
      _msg(T.t("Empty fields", "හිස් තැන් ඇත"));
      return;
    }
    if (!_isValidEmail(email)) {
      _msg(T.t("Invalid email", "වැරදි ඊමේල් ලිපිනයක්"));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(email: email, password: password);

      if (result["success"] == true) {
        final user = result["user"];

        if (user == null) {
          _msg(T.t("Login success but user data missing", "පිවිසීම සාර්ථකයි, නමුත් පරිශීලක දත්ත නැත"));
          return;
        }

        final prefs = await SharedPreferences.getInstance();

        final int userId = int.tryParse(user["user_id"].toString()) ?? 0;
        await prefs.setInt("user_id", userId);

        await prefs.setString("first_name", (user["first_name"] ?? "").toString());
        await prefs.setString("last_name", (user["last_name"] ?? "").toString());
        await prefs.setString("email", (user["email"] ?? "").toString());
        await prefs.setString("role", (user["role"] ?? "").toString());

        // ✅ ADD THIS (important): mark user as logged in for next app open
        // Use any stable value as token; if your API returns a real token, store it here instead.
        await AuthService.loginSuccess(token: userId.toString());

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AddDevicePage()),
        );
      } else {
        _msg((result["message"] ?? T.t("Login failed", "පිවිසීම අසාර්ථකයි")).toString());
      }
    } catch (e) {
      _msg(T.t("Error: $e", "දෝෂය: $e"));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            // ✅ Language buttons (small, no UI redesign)
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    await AppLangController.instance.setLang("en");
                    setState(() {});
                  },
                  child: const Text("English"),
                ),
                TextButton(
                  onPressed: () async {
                    await AppLangController.instance.setLang("si");
                    setState(() {});
                  },
                  child: const Text("සිංහල"),
                ),
              ],
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
                  Text(
                    T.t('     User', '     පරිශීලකයා'),
                    style: const TextStyle(
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
                      hintText: T.t('Enter email', 'ඊමේල් ලියන්න'),
                      hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: T.t('Enter password', 'මුරපදය ලියන්න'),
                      hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: _openForgotPassword,
                      child: Text(
                        T.t('forget password?', 'මුරපදය අමතකද?'),
                        style: const TextStyle(
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
                          : Text(
                              T.t('Login', 'පිවිසෙන්න'),
                              style: const TextStyle(
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
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        T.t("Don't have any account? Sign Up", "ගිණුමක් නැද්ද? ලියාපදිංචි වන්න"),
                        style: const TextStyle(
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