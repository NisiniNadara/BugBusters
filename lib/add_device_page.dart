import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _deviceNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  int _userId = 0;
  bool _isLoading = false;

  final String baseUrl = "http://10.0.2.2/flutter_application_2-main/api";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _firstNameCtrl.text = (prefs.getString("first_name") ?? "").trim();
    _emailCtrl.text = (prefs.getString("email") ?? "").trim();

    // user_id load
    _userId = prefs.getInt("user_id") ?? 0;
    if (_userId == 0) {
      _userId = int.tryParse(prefs.getString("user_id") ?? "") ?? 0;
    }

    if (mounted) setState(() {});
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addDevice() async {
    final firstName = _firstNameCtrl.text.trim();
    final deviceName = _deviceNameCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (_userId <= 0) {
      _showSnack("User ID missing. Please login again.");
      return;
    }

    if (firstName.isEmpty) {
      _showSnack("First name missing. Please login again.");
      return;
    }

    if (deviceName.isEmpty || location.isEmpty) {
      _showSnack("Please fill Device Name and Pump Location");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/add_pump.php");

      // send user_id + pump_name + location to backend
      final payload = {
        "user_id": _userId,
        "pump_name": deviceName,
        "location": location,
        "pump_location": location, 
      };

      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final raw = res.body.trim();
      if (raw.isEmpty) {
        _showSnack("Server returned empty response. Check add_pump.php");
        return;
      }

      Map<String, dynamic> data;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          _showSnack("Server response is not JSON object");
          return;
        }
      } catch (_) {
        final short = raw.length > 220 ? raw.substring(0, 220) : raw;
        _showSnack("Server not JSON (HTTP ${res.statusCode}): $short");
        return;
      }

      if (data["success"] == true) {
        _showSnack((data["message"] ?? "Device added successfully").toString());
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
      } else {
        _showSnack((data["message"] ?? "Failed to add device").toString());
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage()),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _deviceNameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Add Device",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A5319),
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              decoration: const BoxDecoration(
                color: Color(0xFF1A5319),
                borderRadius: BorderRadius.only(topRight: Radius.circular(120)),
              ),
              child: Column(
                children: [
                  _inputField(title: "First Name", controller: _firstNameCtrl, readOnly: true),
                  const SizedBox(height: 12),
                  _inputField(title: "Email", controller: _emailCtrl, readOnly: true),
                  const SizedBox(height: 12),
                  _inputField(title: "Device Name", controller: _deviceNameCtrl),
                  const SizedBox(height: 12),
                  _inputField(title: "Pump Location", controller: _locationCtrl),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Already added the device then skip",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isLoading ? null : _addDevice,
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _skip,
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Widget _inputField({
    required String title,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
