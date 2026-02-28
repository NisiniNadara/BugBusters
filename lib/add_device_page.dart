import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_lang.dart';
import 'dashboard_page.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
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
    final deviceName = _deviceNameCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (_userId <= 0) {
      _showSnack(T.t("User ID missing. Please login again.", "User ID නැත. කරුණාකර නැවත Login වන්න."));
      return;
    }

    if (deviceName.isEmpty || location.isEmpty) {
      _showSnack(T.t("Please fill Pump Name and Pump Location", "කරුණාකර පම්ප් නාමය සහ පම්ප් ස්ථානය පුරවන්න"));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/add_pump.php");

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
        _showSnack(T.t("Server returned empty response. Check add_pump.php", "Server එකෙන් හිස් ප්‍රතිචාරයක් ආවා. add_pump.php පරීක්ෂා කරන්න"));
        return;
      }

      Map<String, dynamic> data;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          _showSnack(T.t("Server response is not JSON object", "Server ප්‍රතිචාරය JSON object එකක් නෙවේ"));
          return;
        }
      } catch (_) {
        final short = raw.length > 220 ? raw.substring(0, 220) : raw;
        _showSnack(T.t("Server not JSON (HTTP ${res.statusCode}): $short", "Server JSON නෙවේ (HTTP ${res.statusCode}): $short"));
        return;
      }

      if (data["success"] == true) {
        _showSnack((data["message"] ?? T.t("Device added successfully", "උපාංගය සාර්ථකව එකතු විය")).toString());
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
      } else {
        _showSnack((data["message"] ?? T.t("Failed to add device", "උපාංගය එකතු කිරීම අසාර්ථකයි")).toString());
      }
    } catch (e) {
      _showSnack(T.t("Error: $e", "දෝෂය: $e"));
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
            Text(
              T.t("Add Pump", "පම්ප් එක එක් කරන්න"),
              style: const TextStyle(
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
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                ),
              ),
              child: Column(
                children: [
                  _inputField(
                    title: T.t("Pump Name", "පම්ප් නාමය"),
                    controller: _deviceNameCtrl,
                    hintText: T.t("Enter suitable name for your pump", "ඔබගේ පම්ප් එකට සුදුසු නමක් ලියන්න"),
                  ),
                  const SizedBox(height: 12),
                  _inputField(
                    title: T.t("Pump Location", "පම්ප් ස්ථානය"),
                    controller: _locationCtrl,
                    hintText: T.t("Where is your pump locate?", "ඔබගේ පම්ප් එක පිහිටා ඇති ස්ථානය කොහිද?"),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      T.t("Already added the device then skip", "උපාංගය දැනටමත් එක් කරලා නම් Skip කරන්න"),
                      style: const TextStyle(
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
                          : Text(
                              T.t("Add", "එක් කරන්න"),
                              style: const TextStyle(
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
                      child: Text(
                        T.t("Skip", "මඟහරින්න"),
                        style: const TextStyle(
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
    String? hintText,
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}