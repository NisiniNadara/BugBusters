import 'package:flutter/material.dart';
import 'app_lang.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pump_health_page.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';
import 'api_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  static const Color darkGreen = Color(0xFF1A5319);
  static const Color lightGreen = Color(0xFFD6F5EC);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Map<String, dynamic>> alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);

    try {
      final sp = await SharedPreferences.getInstance();

      
      final dynamic rawUserId = sp.get("user_id");
      final String userId = rawUserId?.toString() ?? "";

      if (userId.trim().isEmpty) {
        setState(() {
          alerts = [];
          _loading = false;
        });
        return;
      }

      final res = await ApiService.fetchAlerts(userId: userId);

      if (res["success"] == true && res["alerts"] is List) {
        final list = (res["alerts"] as List)
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        
        final converted = list.map((a) {
          final title = (a["title"] ?? a["alert_type"] ?? "Alert").toString();
          final severity = (a["severity"] ?? "low").toString().toLowerCase();
          final createdAt =
              (a["created_at"] ?? a["alert_date"] ?? "").toString();

          return {
            "title": title,
            "time": _formatTime(createdAt),
            "active": severity == "high" || severity == "medium",
            "severity": severity,
            "message": (a["message"] ?? "").toString(),
          };
        }).toList();

        setState(() {
          alerts = converted;
          _loading = false;
        });
      } else {
        setState(() {
          alerts = [];
          _loading = false;
        });

        if (!mounted) return;
        final msg = (res["message"] ?? "Failed to load alerts").toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      setState(() {
        alerts = [];
        _loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading alerts: $e")),
      );
    }
  }

  Future<void> _refresh() async {
    await _loadAlerts();
  }

  String _formatTime(String ts) {
    try {
      final dt = DateTime.parse(ts.replaceFirst(' ', 'T'));
      return DateFormat("yyyy-MM-dd  HH:mm").format(dt);
    } catch (_) {
      return ts.isEmpty ? "Unknown time" : ts;
    }
  }

  String _severityLabel(String severity) {
    final s = severity.toLowerCase();
    if (s == "high") return "HIGH";
    if (s == "medium") return "MEDIUM";
    return "LOW";
  }

  void deleteAlert(int index) {
    setState(() {
      alerts.removeAt(index);
    });
  }

  void clearAllAlerts() {
    setState(() {
      alerts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: InkWell(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, color: AlertsPage.darkGreen),
                    SizedBox(width: 6),
                    Text(
                      "Back",
                      style: TextStyle(
                        color: AlertsPage.darkGreen,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                T.t("Alerts","ඇලර්ට්ස්"),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AlertsPage.darkGreen,
                ),
              ),
            ),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(thickness: 2),
            ),
            const SizedBox(height: 6),

            // Alerts List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _loading
                    ? ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : alerts.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 200),
                              Center(
                                child: Text(
                                  "No alerts available",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 30),
                            itemCount: alerts.length,
                            itemBuilder: (context, index) {
                              final alert = alerts[index];

                              return AlertItem(
                                title: (alert["title"] ?? "").toString(),
                                time: (alert["time"] ?? "").toString(),
                                active: alert["active"] == true,
                                severity: _severityLabel(
                                  (alert["severity"] ?? "low").toString(),
                                ),
                                message: (alert["message"] ?? "").toString(),
                                onDelete: () => deleteAlert(index),
                              );
                            },
                          ),
              ),
            ),

            const SizedBox(height: 20),

            // Clear All Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AlertsPage.darkGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 52,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: clearAllAlerts,
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

// Alert Card
class AlertItem extends StatelessWidget {
  final String title;
  final String time;
  final bool active;
  final String severity;
  final String message;
  final VoidCallback onDelete;

  const AlertItem({
    super.key,
    required this.title,
    required this.time,
    this.active = false,
    required this.severity,
    required this.message,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AlertsPage.lightGreen : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      severity,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AlertsPage.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline,
              color: AlertsPage.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Nav Bar
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: AlertsPage.darkGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItem(
            icon: Icons.dashboard,
            label: T.t("Dashboard","ඩෑෂ්බෝඩ්"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardPage()),
              );
            },
          ),
          BottomNavItem(
            icon: Icons.favorite,
            label: T.t("Health","සෞඛ්‍යය"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PumpHealthPage()),
              );
            },
          ),
          BottomNavItem(
            icon: Icons.warning_amber_outlined,
            label: T.t("Alerts","ඇලර්ට්ස්"),
            isActive: true,
          ),
          BottomNavItem(
            icon: Icons.settings,
            label: T.t("Settings","සැකසුම්"),
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

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  BottomNavItem({
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isActive ? 54 : 22,
              height: isActive ? 54 : 22,
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: AlertsPage.darkGreen,
                      border: Border.all(color: Colors.white, width: 5),
                    )
                  : null,
              child: Icon(
                icon,
                color: Colors.white,
                size: isActive ? 22 : 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.red : Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
