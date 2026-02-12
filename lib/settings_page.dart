import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_page.dart';
import 'pump_health_page.dart';
import 'alerts_page.dart';
import 'main.dart';
import 'add_device_page.dart';
import 'change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Pumps list
  List<Map<String, dynamic>> _pumps = [];
  String _selectedPumpName = "Device";

  // Role dropdown value
  String _selectedRole = "Farmer";

  @override
  void initState() {
    super.initState();
    _loadProfileFromPrefs();
    _loadPumpsForUser();

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

    final fullName = [_firstName, _lastName].where((s) => s.isNotEmpty).join(" ").trim();

    setState(() {
      nameController.text = fullName.isEmpty ? "User" : fullName;
      emailController.text = email.isEmpty ? "No email" : email;
      roleController.text = role.isEmpty ? "Role" : role;

      // set dropdown role
      _selectedRole = (role == "Technician") ? "Technician" : "Farmer";

      final a = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : "";
      final b = _lastName.isNotEmpty ? _lastName[0].toUpperCase() : "";
      _avatarText = (a + b).isNotEmpty ? (a + b) : "U";
    });
  }

  // PROFILE UPDATE TO BACKEND
  Future<void> _saveProfileToBackend() async {
    // Name controller contains "First Last"
    final fullName = nameController.text.trim();
    final parts = fullName.split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) {
      _showSnack("Name required");
      return;
    }

    final first = parts.first;
    final last = (parts.length >= 2) ? parts.sublist(1).join(" ") : _lastName;

    final email = emailController.text.trim();
    final role = _selectedRole.trim();

    if (_userId <= 0) {
      _showSnack("User ID not found. Please login again.");
      return;
    }
    if (email.isEmpty || !email.contains("@")) {
      _showSnack("Valid email required");
      return;
    }
    if (role.isEmpty) {
      _showSnack("Role required");
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
        _showSnack("Server did not return JSON. HTTP ${res.statusCode}");
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

        _showSnack("Profile updated");
      } else {
        _showSnack((data["message"] ?? "Update failed").toString());
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  // Get pumps for dropdown
  Future<void> _loadPumpsForUser() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("user_id") ?? 0;
    if (userId == 0) {
      userId = int.tryParse(prefs.getString("user_id") ?? "") ?? 0;
    }
    if (userId == 0) return;

    try {
      final url = Uri.parse("$baseUrl/get_pumps.php");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        return;
      }

      if (res.statusCode == 200 && data["success"] == true) {
        final List list = (data["pumps"] ?? []) as List;
        final pumps = list
            .map((e) => {
                  "pump_id": e["pump_id"],
                  "pump_name": e["pump_name"],
                })
            .toList();

        final savedPumpName = prefs.getString("selected_pump_name") ?? "";

        setState(() {
          _pumps = pumps;
          if (savedPumpName.isNotEmpty) {
            _selectedPumpName = savedPumpName;
          } else if (_pumps.isNotEmpty) {
            _selectedPumpName = _pumps.first["pump_name"].toString();
          } else {
            _selectedPumpName = "Device";
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSelectedPump(String pumpName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_pump_name", pumpName);
  }

  void _openDeviceMenu(TapDownDetails details) {
    final position = details.globalPosition;
    final items = <PopupMenuEntry<String>>[];

    if (_pumps.isNotEmpty) {
      for (final p in _pumps) {
        final pumpName = (p["pump_name"] ?? "").toString();
        if (pumpName.isEmpty) continue;

        items.add(PopupMenuItem(value: pumpName, child: Text(pumpName)));
      }
      items.add(const PopupMenuDivider());
    } else {
      items.add(const PopupMenuItem(
        value: "_no_pumps",
        enabled: false,
        child: Text("No pumps added"),
      ));
      items.add(const PopupMenuDivider());
    }

    items.add(const PopupMenuItem(
      value: 'add_device',
      child: Row(
        children: [
          Icon(Icons.add, color: darkGreen),
          SizedBox(width: 6),
          Text("Add Device",
              style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600)),
        ],
      ),
    ));

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx - 160, position.dy + 10, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      items: items,
    ).then((value) async {
      if (value == null) return;

      if (value == 'add_device') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddDevicePage()))
            .then((_) => _loadPumpsForUser());
        return;
      }

      if (value == "_no_pumps") return;

      setState(() => _selectedPumpName = value);
      await _saveSelectedPump(value);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MyApp()),
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  GestureDetector(
                    onTapDown: _openDeviceMenu,
                    child: Row(
                      children: [
                        Text(
                          _selectedPumpName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: darkGreen),
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
                        const Text("Profile",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: darkGreen,
                              child: Text(
                                _avatarText,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name (editable)
                                  isEditingProfile
                                      ? _editField(nameController, "Name")
                                      : Text(nameController.text,
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),

                                  // Email (editable)
                                  isEditingProfile
                                      ? _editField(emailController, "Email")
                                      : Text(emailController.text,
                                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 4),

                                  // Role (dropdown when editing)
                                  isEditingProfile
                                      ? _roleDropdown()
                                      : Chip(
                                          label: Text(roleController.text,
                                              style: const TextStyle(fontSize: 11, color: darkGreen)),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _savingProfile
                                ? null
                                : () async {
                                    if (!isEditingProfile) {
                                      setState(() => isEditingProfile = true);
                                      return;
                                    }
                                    // Save profile to backend
                                    await _saveProfileToBackend();
                                  },
                            child: Text(
                              isEditingProfile ? (_savingProfile ? "Saving..." : "Save Profile") : "Edit Profile",
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
                        const Text("Notifications",
                            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                        _switchTile(
                          title: "Push Notifications",
                          subtitle: "Receive notifications on your device",
                          value: pushNotifications,
                          onChanged: (v) => setState(() => pushNotifications = v),
                        ),
                        _switchTile(
                          title: "Auto Sync",
                          subtitle: "Automatically sync pump data",
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
                        const Text("Account",
                            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                        _arrowTile(
                          "Change Password",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                          ),
                        ),
                        _arrowTile("Terms of Service"),
                        _arrowTile("Help & Support"),
                      ],
                    ),
                  ),

                  // About
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("About",
                            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("Version : 1.0.0"),
                        Text("Developed by : Bug Busters Team"),
                      ],
                    ),
                  ),

                  // Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _logout,
                      child: const Text("Logout", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  // Role dropdown 
  Widget _roleDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedRole,
        isDense: true,
        items: const [
          DropdownMenuItem(value: "Farmer", child: Text("Farmer")),
          DropdownMenuItem(value: "Technician", child: Text("Technician")),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
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

// Bottom Navigation
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

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
          _item(context, Icons.dashboard, "Dashboard", const DashboardPage()),
          _item(context, Icons.favorite, "Health", const PumpHealthPage()),
          _item(context, Icons.warning_amber_outlined, "Alerts", const AlertsPage()),
          _item(context, Icons.settings, "Settings", null, active: true),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, Widget? page,
      {bool active = false}) {
    return GestureDetector(
      onTap: page == null
          ? null
          : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.white70)),
        ],
      ),
    );
  }
}
