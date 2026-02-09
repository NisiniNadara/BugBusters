import 'package:flutter/material.dart';
import 'second_page.dart';
import 'api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => email.contains("@") && email.contains(".");

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.register(
  firstName: first,
  lastName: last,
  email: email,
  password: password,
);

    

      if (result["success"] == true) {
        _showMsg("Register success. Please login.");

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SecondPage()),
          (route) => false,
        );
      } else {
        _showMsg((result["message"] ?? "Register failed").toString());
      }
    } catch (e) {
      _showMsg("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A5319)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A5319),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF1A5319),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildField(
                      label: 'first Name',
                      controller: firstNameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'First name required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'last Name',
                      controller: lastNameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Last name required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'email',
                      controller: emailController,
                      validator: (v) {
                        final val = (v ?? "").trim();
                        if (val.isEmpty) return 'Email required';
                        if (!_isValidEmail(val)) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'password',
                      controller: passwordController,
                      isPassword: true,
                      validator: (v) {
                        final val = (v ?? "").trim();
                        if (val.isEmpty) return 'Password required';
                        if (val.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'Confirm password',
                      controller: confirmPasswordController,
                      isPassword: true,
                      validator: (v) {
                        if ((v ?? "") != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleSignUp,
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.yellow),
      ),
    );
  }
}
