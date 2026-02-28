import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_lang.dart';
import 'dashboard_page.dart';
import 'pump_health_page.dart';
import 'alerts_page.dart';
import 'main.dart';
import 'change_password_page.dart';
import 'terms_of_service_page.dart';
import 'help_support_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ ADD THESE imports (no UI change)
import 'auth/auth_service.dart';
// ❌ removed: import 'second_page.dart';

class SettingsPage extends StatefulWidget {
  final bool openChangePassword;

  const SettingsPage({
    super.key,
    this.openChangePassword = false,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool autoSync = true;
  bool isEditingProfile = false;
  bool _savingProfile = false;

  static const Color darkGreen = Color(0xFF1A5319);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final roleController = TextEditingController();

  String _firstName = "";
  String _lastName = "";
  int _userId = 0;

  String _avatarText = "U";

  final String baseUrl = "http://10.0.2.2/flutter_application_2-main/api";

  // Role dropdown value
  String _selectedRole = "Farmer";

  @override
  void initState() {
    super.initState();
    _loadProfileFromPrefs();

    if (widget.openChangePassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
        );
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getInt("user_id") ?? 0;
    if (_userId == 0) {
      _userId = int.tryParse(prefs.getString("user_id") ?? "") ?? 0;
    }

    _firstName = (prefs.getString("first_name") ?? "").trim();
    _lastName = (prefs.getString("last_name") ?? "").trim();

    final email = (prefs.getString("email") ?? "").trim();
    final role = (prefs.getString("role") ?? "").trim();

    final fullName =
        [_firstName, _lastName].where((s) => s.isNotEmpty).join(" ").trim();

    setState(() {
      nameController.text = fullName.isEmpty ? T.t("User", "පරිශීලකයා") : fullName;
      emailController.text = email.isEmpty ? T.t("No email", "ඊමේල් නැත") : email;
      roleController.text = role.isEmpty ? T.t("Role", "භූමිකාව") : role;

      _selectedRole = (role == "Technician") ? "Technician" : "Farmer";

      final a = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : "";
      final b = _lastName.isNotEmpty ? _lastName[0].toUpperCase() : "";
      _avatarText = (a + b).isNotEmpty ? (a + b) : "U";
    });
  }

  // PROFILE UPDATE TO BACKEND
  Future<void> _saveProfileToBackend() async {
    final fullName = nameController.text.trim();
    final parts =
        fullName.split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) {
      _showSnack(T.t("Name required", "නම අවශ්‍යයි"));
      return;
    }

    final first = parts.first;
    final last = (parts.length >= 2) ? parts.sublist(1).join(" ") : _lastName;

    final email = emailController.text.trim();
    final role = _selectedRole.trim();

    if (_userId <= 0) {
      _showSnack(T.t("User ID not found. Please login again.",
          "User ID නැත. කරුණාකර නැවත Login වන්න."));
      return;
    }
    if (email.isEmpty || !email.contains("@")) {
      _showSnack(T.t("Valid email required", "වලංගු ඊමේල් ලිපිනයක් අවශ්‍යයි"));
      return;
    }
    if (role.isEmpty) {
      _showSnack(T.t("Role required", "භූමිකාව අවශ්‍යයි"));
      return;
    }

    setState(() => _savingProfile = true);

    try {
      final url = Uri.parse("$baseUrl/update_profile.php");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": _userId,
          "first_name": first,
          "last_name": last,
          "email": email,
          "role": role,
        }),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        _showSnack(T.t("Server did not return JSON. HTTP ${res.statusCode}",
            "Server එක JSON ආපසු දුන්නේ නැහැ. HTTP ${res.statusCode}"));
        return;
      }

      if (res.statusCode == 200 && data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("first_name", first);
        await prefs.setString("last_name", last);
        await prefs.setString("email", email);
        await prefs.setString("role", role);

        _firstName = first;
        _lastName = last;

        setState(() {
          roleController.text = role;
          isEditingProfile = false;

          final a = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : "";
          final b = _lastName.isNotEmpty ? _lastName[0].toUpperCase() : "";
          _avatarText = (a + b).isNotEmpty ? (a + b) : "U";
        });

        _showSnack(T.t("Profile updated", "පැතිකඩ යාවත්කාලීන විය"));
      } else {
        _showSnack((data["message"] ??
                T.t("Update failed", "යාවත්කාලීන කිරීම අසාර්ථකයි"))
            .toString());
      }
    } catch (e) {
      _showSnack(T.t("Error: $e", "දෝෂය: $e"));
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  // ✅ ONLY CHANGE HERE: logout should go to main.dart (MyApp) instead of SecondPage
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // ✅ Important for "login once then dashboard"
    await AuthService.logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MyApp()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (UNCHANGED UI)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: darkGreen),
                        const SizedBox(width: 6),
                        Text(
                          T.t("Back", "ආපසු"),
                          style: const TextStyle(color: darkGreen, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  // Profile card
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          T.t("Profile", "පැතිකඩ"),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: darkGreen,
                              child: Text(
                                _avatarText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isEditingProfile
                                      ? _editField(nameController, T.t("Name", "නම"))
                                      : Text(
                                          nameController.text,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                  const SizedBox(height: 2),
                                  isEditingProfile
                                      ? _editField(emailController, T.t("Email", "ඊමේල්"))
                                      : Text(
                                          emailController.text,
                                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                                        ),
                                  const SizedBox(height: 4),
                                  isEditingProfile
                                      ? _roleDropdown()
                                      : Chip(
                                          label: Text(
                                            roleController.text,
                                            style: const TextStyle(fontSize: 11, color: darkGreen),
                                          ),
                                          backgroundColor: const Color(0xFFD6F5EC),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _savingProfile
                                ? null
                                : () async {
                                    if (!isEditingProfile) {
                                      setState(() => isEditingProfile = true);
                                      return;
                                    }
                                    await _saveProfileToBackend();
                                  },
                            child: Text(
                              isEditingProfile
                                  ? (_savingProfile
                                      ? T.t("Saving...", "සුරකිමින්...")
                                      : T.t("Save Profile", "පැතිකඩ සුරකින්න"))
                                  : T.t("Edit Profile", "පැතිකඩ සංස්කරණය"),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notifications
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          T.t("Notifications", "දැනුම්දීම්"),
                          style: const TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _switchTile(
                          title: T.t("Push Notifications", "දැනුම්දීම් එවන්න"),
                          subtitle: T.t("Receive notifications on your device",
                              "ඔබගේ දුරකථනයට දැනුම්දීම් ලැබේ"),
                          value: pushNotifications,
                          onChanged: (v) => setState(() => pushNotifications = v),
                        ),
                        _switchTile(
                          title: T.t("Auto Sync", "ස්වයංක්‍රීය සින්ක්"),
                          subtitle: T.t("Automatically sync pump data",
                              "පම්ප් දත්ත ස්වයංක්‍රීයව සින්ක් වේ"),
                          value: autoSync,
                          onChanged: (v) => setState(() => autoSync = v),
                        ),
                      ],
                    ),
                  ),

                  // Account
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          T.t("Account", "ගිණුම"),
                          style: const TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _arrowTile(
                          T.t("Change Password", "මුරපදය වෙනස් කරන්න"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                          ),
                        ),
                        _arrowTile(
                          T.t("Terms of Service", "සේවා නියමයන්"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
                          ),
                        ),
                        _arrowTile(
                          T.t("Help & Support", "උදව් සහ සහාය"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // About
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          T.t("About", "විස්තර"),
                          style: const TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(T.t("Version : 1.0.0", "අනුවාදය : 1.0.0")),
                        Text(T.t("Developed by : Bug Busters Team",
                            "සංවර්ධනය කළේ : Bug Busters කණ්ඩායම")),
                      ],
                    ),
                  ),

                  // Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _logout,
                      child: Text(
                        T.t("Logout", "පිටවන්න"),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }

  // Role dropdown
  Widget _roleDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedRole,
        isDense: true,
        items: [
          DropdownMenuItem(value: "Farmer", child: Text(T.t("Farmer", "ගොවියා"))),
          DropdownMenuItem(value: "Technician", child: Text(T.t("Technician", "තාක්ෂණිකයා"))),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _selectedRole = v;
            roleController.text = v;
          });
        },
      ),
    );
  }

  // Helpers
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      activeColor: darkGreen,
      value: value,
      onChanged: (v) => onChanged(v),
    );
  }

  Widget _arrowTile(String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }

  Widget _editField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}

// Bottom Navigation (UNCHANGED UI)
class _BottomNavBar extends StatelessWidget {
  _BottomNavBar();

  static const Color darkGreen = Color(0xFF1A5319);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, Icons.dashboard, T.t("Dashboard", "ඩෑෂ්බෝඩ්"), const DashboardPage()),
          _item(context, Icons.favorite, T.t("Health", "සෞඛ්‍යය"), const PumpHealthPage()),
          _item(context, Icons.warning_amber_outlined, T.t("Alerts", "ඇලර්ට්ස්"), const AlertsPage()),
          _item(context, Icons.settings, T.t("Settings", "සැකසුම්"), null, active: true),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, Widget? page, {bool active = false}) {
    return GestureDetector(
      onTap: page == null
          ? null
          : () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => page),
              ),
      child: Transform.translate(
        offset: const Offset(0, -4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: active ? 54 : 22,
              height: active ? 54 : 22,
              decoration: active
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkGreen,
                      border: Border.all(color: Colors.white, width: 5),
                    )
                  : null,
              child: Icon(
                icon,
                color: Colors.white,
                size: active ? 22 : 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}