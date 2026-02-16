import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart';

class PumpHealthPage extends StatefulWidget {
  const PumpHealthPage({super.key});

  @override
  State<PumpHealthPage> createState() => _PumpHealthPageState();
}

class _PumpHealthPageState extends State<PumpHealthPage> {
  double temp = 0;
  double vib = 0;
  double pressure = 0;
  double flow = 0;

  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();

    //show saved values
    _loadFromPrefsOnly();

    // refresh UI only every 60 seconds
    _uiTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadFromPrefsOnly();
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFromPrefsOnly() async {
    final prefs = await SharedPreferences.getInstance();
    final newTemp = prefs.getDouble("latest_temp") ?? 0;
    final newVib = prefs.getDouble("latest_vib") ?? 0;
    final newPressure = prefs.getDouble("latest_pressure") ?? 0;
    final newFlow = prefs.getDouble("latest_flow") ?? 0;

    if (!mounted) return;
    setState(() {
      temp = newTemp;
      vib = newVib;
      pressure = newPressure;
      flow = newFlow;
    });
  }

  double _progress(double value, double max) {
    if (max <= 0) return 0;
    final p = value / max;
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  Widget _sensorBar({
    required String title,
    required String valueText,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A5319),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(150),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const DashboardPage()),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Back", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Pump Health Monitor",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(child: GaugeMeter()),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "RUL Time for this Month",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("Line Chart Here", style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _sensorBar(
                    title: "Temperature",
                    valueText: temp == 0 ? "--" : "${temp.toStringAsFixed(1)} C",
                    progress: _progress(temp, 100),
                  ),
                  _sensorBar(
                    title: "Vibration",
                    valueText: vib == 0 ? "--" : "${vib.toStringAsFixed(1)} mm/s",
                    progress: _progress(vib, 5),
                  ),
                  _sensorBar(
                    title: "Pressure",
                    valueText: pressure == 0 ? "--" : "${pressure.toStringAsFixed(0)} PSI",
                    progress: _progress(pressure, 100),
                  ),
                  _sensorBar(
                    title: "Flow Rate",
                    valueText: flow == 0 ? "--" : "${flow.toStringAsFixed(0)} %",
                    progress: _progress(flow, 100),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
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
          BottomItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
          ),
          const BottomItem(icon: Icons.favorite, label: "Health", isActive: true),
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

// GAUGE METER 
class GaugeMeter extends StatelessWidget {
  const GaugeMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 80),
            painter: ArcPainter(startAngle: 3.14, sweepAngle: 2.1, color: Colors.yellow),
          ),
          CustomPaint(
            size: const Size(180, 80),
            painter: ArcPainter(startAngle: 5.3, sweepAngle: 1.1, color: Colors.white70),
          ),
          Transform.rotate(
            angle: -0.5,
            child: Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  ArcPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(10, 10, size.width - 20, size.height * 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
