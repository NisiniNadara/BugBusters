import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'pump_health_page.dart';
import 'alerts_page.dart';
import 'main.dart';
import 'add_device_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool autoSync = true;
  bool isEditingProfile = false;

  static const Color darkGreen = Color(0xFF1A5319);

  // Profile controllers
  final nameController = TextEditingController(text: "Krish Kapoor");
  final emailController =
      TextEditingController(text: "saiyaara2025@gmail.com");
  final roleController = TextEditingController(text: "Farmer");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ───────── Header ─────────
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

                  // Device dropdown
                  GestureDetector(
                    onTapDown: (details) {
                      final position = details.globalPosition;
                      showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            position.dx - 160, position.dy + 10, 16, 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        items: const [
                          PopupMenuItem(value: 'device1', child: Text("Device 01")),
                          PopupMenuItem(value: 'device2', child: Text("Device 02")),
                          PopupMenuItem(value: 'device3', child: Text("Device 03")),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'add_device',
                            child: Row(
                              children: [
                                Icon(Icons.add, color: darkGreen),
                                SizedBox(width: 6),
                                Text("Add Device",
                                    style: TextStyle(
                                        color: darkGreen,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ).then((value) {
                        if (value == 'add_device') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddDevicePage()),
                          );
                        }
                      });
                    },
                    child: Row(
                      children: const [
                        Text("Device",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: darkGreen)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: darkGreen),
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
                  // ───────── Profile Card ─────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Profile",
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: darkGreen,
                              child: Text("KK",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isEditingProfile
                                      ? _editField(nameController, "Name")
                                      : Text(nameController.text,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),

                                  const SizedBox(height: 2),

                                  isEditingProfile
                                      ? _editField(emailController, "Email")
                                      : Text(emailController.text,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54)),

                                  const SizedBox(height: 4),

                                  isEditingProfile
                                      ? _editField(roleController, "Role")
                                      : Chip(
                                          label: Text(roleController.text,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: darkGreen)),
                                          backgroundColor:
                                              const Color(0xFFD6F5EC),
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
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                isEditingProfile = !isEditingProfile;
                              });
                            },
                            child: Text(
                              isEditingProfile ? "Save Profile" : "Edit Profile",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ───────── Notifications ─────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Notifications",
                            style: TextStyle(
                                color: darkGreen,
                                fontWeight: FontWeight.bold)),
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

                  // ───────── Account ─────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Account",
                            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                        _arrowTile("Change Password"),
                        _arrowTile("Terms of Service"),
                        _arrowTile("Help & Support"),
                      ],
                    ),
                  ),

                  // ───────── About ─────────
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

                  // ───────── Logout ─────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => MyApp()),
                          (route) => false,
                        );
                      },
                      child: const Text("Logout",
                          style: TextStyle(color: Colors.red)),
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

  // ───────── Helpers ─────────
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

  Widget _arrowTile(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
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

// ───────── Bottom Navigation ─────────
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
          : () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.white70)),
        ],
      ),
    );
  }
}
