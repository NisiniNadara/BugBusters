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
  final telephoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedRole;

  bool _isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => email.contains("@") && email.contains(".");

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String? _validatePassword(String? v) {
    final val = (v ?? "").trim();
    if (val.isEmpty) return 'Password required';
    if (val.length != 6) return 'Password must be exactly 6 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(val)) {
      return 'Password must include letters';
    }
    if (!RegExp(r'\d').hasMatch(val)) {
      return 'Password must include digits';
    }
    return null;
  }

  String? _validateTelephone(String? v) {
    final val = (v ?? "").trim();
    if (val.isEmpty) return 'Telephone required';
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(val)) {
      return 'Invalid telephone number';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRole == null) {
      _showMsg("Role required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        telephone: telephoneController.text.trim(),
        role: selectedRole!,
        password: passwordController.text.trim(),
      );

      if (result["success"] == true) {
        _showMsg("Registration successful. Confirmation email sent.");

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SecondPage()),
          (route) => false,
        );
      } else {
        _showMsg(result["message"].toString());
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
                    buildField(label: 'first Name', controller: firstNameController),
                    const SizedBox(height: 12),
                    buildField(label: 'last Name', controller: lastNameController),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'email',
                      controller: emailController,
                      validator: (v) =>
                          _isValidEmail(v ?? "") ? null : 'Invalid email',
                    ),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'telephone',
                      controller: telephoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validateTelephone,
                    ),
                    const SizedBox(height: 12),
                    buildRoleDropdown(),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'password',
                      controller: passwordController,
                      isPassword: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 12),
                    buildField(
                      label: 'Confirm password',
                      controller: confirmPasswordController,
                      isPassword: true,
                      validator: (v) =>
                          v == passwordController.text ? null : 'Passwords do not match',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
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

  Widget buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      validator: (v) => v == null ? 'Role required' : null,
      dropdownColor: const Color(0xFF1A5319),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'role',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Farmer", child: Text("Farmer")),
        DropdownMenuItem(value: "Technician", child: Text("Technician")),
      ],
      onChanged: (val) => setState(() => selectedRole = val),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      keyboardType: keyboardType,
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
      ),
    );
  }
}
