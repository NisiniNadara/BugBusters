import 'package:flutter/material.dart';
import 'app_lang.dart';
import 'second_page.dart';
import 'api_service.dart';

// ✅ ADD THIS import (no UI change)
import 'auth/auth_service.dart';

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
    if (val.isEmpty) return T.t('Password required','මුරපදය අවශ්‍යයි');
    if (val.length != 6) return T.t('Password must be exactly 6 characters','මුරපදය අකුරු 6ක් විය යුතුයි');
    if (!RegExp(r'[A-Za-z]').hasMatch(val)) return T.t('Password must include letters','මුරපදයට අකුරු තිබිය යුතුයි');
    if (!RegExp(r'\d').hasMatch(val)) return T.t('Password must include digits','මුරපදයට ඉලක්කම් තිබිය යුතුයි');
    return null;
  }

  String? _validateTelephone(String? v) {
    final val = (v ?? "").trim();
    if (val.isEmpty) return T.t('Telephone required','දුරකථන අවශ්‍යයි');
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(val)) {
      return T.t('Invalid telephone number','වැරදි දුරකථන අංකය');
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

        // ✅ ADD THIS: mark user as logged in so next time app goes to Dashboard
        // If your API returns a real token/user_id, store that instead.
        await AuthService.loginSuccess(token: emailController.text.trim());

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

      // (Optional but recommended) helps when keyboard opens
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // keeps same look but allows scroll on small heights
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Color(0xFF1A5319)),
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

                      // keeps the green container at the bottom when space allows
                      const Expanded(child: SizedBox()),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A5319),
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(80)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              buildField(
                                label: 'first Name',
                                controller: firstNameController,
                              ),
                              const SizedBox(height: 12),
                              buildField(
                                label: 'last Name',
                                controller: lastNameController,
                              ),
                              const SizedBox(height: 12),
                              buildField(
                                label: 'email',
                                controller: emailController,
                                validator: (v) => _isValidEmail(v ?? "")
                                    ? null
                                    : T.t('Invalid email','වැරදි ඊමේල්'),
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
                                    (v ?? "") == passwordController.text
                                        ? null
                                        : T.t('Passwords do not match','මුරපද එකක් නොවේ'),
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
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      validator: (v) => v == null ? T.t('Role required','භූමිකාව අවශ්‍යයි') : null,
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
      items: [
        DropdownMenuItem(value: "Farmer", child: Text(T.t("Farmer","ගොවියා"))),
        DropdownMenuItem(value: "Technician", child: Text(T.t("Technician","තාක්ෂණිකයා"))),
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