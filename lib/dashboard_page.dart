import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString("first_name") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  TOP GREEN HEADER
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
                    const Text(
                      "Welcome back,",
                      style: TextStyle(color: Colors.white70),
                    ),
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

              //  RUL CARD
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "Remaining useful Life\n(RUL)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5319),
                        ),
                      ),
                      SizedBox(height: 4),
                      Divider(thickness: 1, indent: 40, endIndent: 40),
                      SizedBox(height: 6),
                      Text(
                        "45",
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        "Days Remaining",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              //  PUMP HEALTH STATUS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        StatusBox(
                          title: "Temperature",
                          value: "68 C",
                          icon: Icons.thermostat,
                          borderColor: Colors.red,
                        ),
                        SizedBox(width: 12),
                        StatusBox(
                          title: "Vibration",
                          value: "3.2 mm/s",
                          icon: Icons.waves,
                          borderColor: Colors.lightGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        StatusBox(
                          title: "Pressure",
                          value: "42 PSI",
                          icon: Icons.speed,
                          borderColor: Colors.lightGreen,
                        ),
                        SizedBox(width: 12),
                        StatusBox(
                          title: "Flow Rate",
                          value: "85 %",
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

      // BOTTOM NAV BAR
      bottomNavigationBar: _bottomBar(context),
    );
  }

  // BOTTOM BAR
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
          // DASHBOARD
          BottomItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            isActive: true,
            onTap: () {},
          ),

          // HEALTH
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

          // ALERTS
          BottomItem(
            icon: Icons.warning_amber_outlined,
            label: "Alerts",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsPage()),
              );
            },
          ),

          // SETTINGS
          BottomItem(
            icon: Icons.settings,
            label: "Settings",
            onTap: () {
              Navigator.push(
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

// STATUS BOX
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// BOTTOM ITEM
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
              child: Icon(
                icon,
                size: isActive ? 22 : 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
