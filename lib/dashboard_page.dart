import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pump_health_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String firstName = "";

  // show from prefs
  String temperatureText = "-- C";
  String vibrationText = "-- mm/s";
  String pressureText = "-- PSI";
  String flowText = "-- %";

  int rulDays = 45;

  Timer? _timer;

  // your base url
  final String baseUrl =
      "http://192.168.109.136/flutter_application_2-main/api";

  @override
  void initState() {
    super.initState();
    _loadUserName();

    // show last saved values immediately
    _loadFromPrefsOnly();

    _loadOrUpdateRulOncePerDay();

    
    _fetchPumpStatusAndSave();

    // every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchPumpStatusAndSave();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      firstName = prefs.getString("first_name") ?? "";
    });
  }

  Future<void> _loadOrUpdateRulOncePerDay() async {
    final prefs = await SharedPreferences.getInstance();

    final lastTimeMillis = prefs.getInt("latest_rul_time") ?? 0;
    final savedRul = prefs.getInt("latest_rul") ?? 45;

    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    const oneDayMillis = 24 * 60 * 60 * 1000;

    if (lastTimeMillis == 0 || (nowMillis - lastTimeMillis) >= oneDayMillis) {
      int newRul = savedRul - 1;
      if (newRul < 0) newRul = 0;

      await prefs.setInt("latest_rul", newRul);
      await prefs.setInt("latest_rul_time", nowMillis);

      if (!mounted) return;
      setState(() => rulDays = newRul);
    } else {
      if (!mounted) return;
      setState(() => rulDays = savedRul);
    }
  }

  // read prefs only (NO backend)
  Future<void> _loadFromPrefsOnly() async {
    final prefs = await SharedPreferences.getInstance();

    final t = prefs.getDouble("latest_temp");
    final v = prefs.getDouble("latest_vib");
    final p = prefs.getDouble("latest_pressure");
    final f = prefs.getDouble("latest_flow");

    if (!mounted) return;

    setState(() {
      temperatureText = t == null ? "-- C" : "$t C";
      vibrationText = v == null ? "-- mm/s" : "$v mm/s";
      pressureText = p == null ? "-- PSI" : "$p PSI";
      flowText = f == null ? "-- %" : "$f %";
    });
  }

  
  Future<void> _fetchPumpStatusAndSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dynamic rawUserId = prefs.get("user_id");
      final String userId = rawUserId?.toString() ?? "";

      if (userId.isEmpty || userId == "0") return;

      final url = Uri.parse("$baseUrl/get_dashboard_status.php");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      final decoded = jsonDecode(res.body);

      if (decoded is Map && decoded["success"] == true && decoded["data"] is Map) {
        final Map d = decoded["data"] as Map;

        double toD(dynamic v) => double.tryParse(v?.toString() ?? "") ?? 0;

        final temp = toD(d["temperature"]);
        final vib = toD(d["vibration"]);
        final pres = toD(d["pressure"]);
        final flow = toD(d["flow_rate"]);

        
        await prefs.setDouble("latest_temp", temp);
        await prefs.setDouble("latest_vib", vib);
        await prefs.setDouble("latest_pressure", pres);
        await prefs.setDouble("latest_flow", flow);

        //same values Health will read
        await _loadFromPrefsOnly();
      }
    } catch (_) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A5319),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text("Welcome back,", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(
                      firstName.isEmpty ? "Welcome !" : "$firstName !",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Remaining useful Life\n(RUL)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5319),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(thickness: 1, indent: 40, endIndent: 40),
                      const SizedBox(height: 6),
                      Text(
                        "$rulDays",
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const Text("Days Remaining", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pump Health Status",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StatusBox(
                          title: "Temperature",
                          value: temperatureText,
                          icon: Icons.thermostat,
                          borderColor: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        StatusBox(
                          title: "Vibration",
                          value: vibrationText,
                          icon: Icons.waves,
                          borderColor: Colors.lightGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StatusBox(
                          title: "Pressure",
                          value: pressureText,
                          icon: Icons.speed,
                          borderColor: Colors.lightGreen,
                        ),
                        const SizedBox(width: 12),
                        StatusBox(
                          title: "Flow Rate",
                          value: flowText,
                          icon: Icons.show_chart,
                          borderColor: Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(context),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF1A5319),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomItem(icon: Icons.dashboard, label: "Dashboard", isActive: true, onTap: () {}),
          BottomItem(
            icon: Icons.favorite_border,
            label: "Health",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PumpHealthPage()),
              );
            },
          ),
          BottomItem(
            icon: Icons.warning_amber_outlined,
            label: "Alerts",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AlertsPage()),
              );
            },
          ),
          BottomItem(
            icon: Icons.settings,
            label: "Settings",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color borderColor;

  const StatusBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const BottomItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isActive ? 54 : 22,
              height: isActive ? 54 : 22,
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A5319),
                      border: Border.all(color: Colors.white, width: 5),
                    )
                  : null,
              child: Icon(icon, size: isActive ? 22 : 20, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, height: 1.0, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
