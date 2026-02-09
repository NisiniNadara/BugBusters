import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart'; 

class PumpHealthPage extends StatelessWidget {
  const PumpHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  TOP CURVED HEADER
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
                    // 🔙 BACK BUTTON
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.arrow_back, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "Back",
                              style: TextStyle(color: Colors.white),
                            ),
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

              const SizedBox(height: 20),

              // RUL TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "RUL Time for this Month",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //  LINE CHART PLACEHOLDER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Line Chart Here",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //  MINI GAUGES
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    MiniGauge(label: "Temperature", color: Colors.red),
                    MiniGauge(label: "Vibration", color: Colors.green),
                    MiniGauge(label: "Pressure", color: Colors.amber),
                    MiniGauge(label: "Flow Rate", color: Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),

      // 🔹 BOTTOM NAV BAR
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
          // Dashboard
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

          // Health (ACTIVE)
          const BottomItem(
            icon: Icons.favorite,
            label: "Health",
            isActive: true,
          ),

          // Alerts
          BottomItem(
            icon: Icons.warning_amber_outlined,
            label: "Alerts",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlertsPage(),
                ),
              );
            },
          ),

          // SETTINGS (FIXED)
          BottomItem(
            icon: Icons.settings,
            label: "Settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
//  GAUGE METER
//////////////////////////////////////////////////////////////

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
            painter: ArcPainter(
              startAngle: 3.14,
              sweepAngle: 2.1,
              color: Colors.yellow,
            ),
          ),
          CustomPaint(
            size: const Size(180, 80),
            painter: ArcPainter(
              startAngle: 5.3,
              sweepAngle: 1.1,
              color: Colors.white70,
            ),
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

//////////////////////////////////////////////////////////////
// ARC PAINTER
//////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////
// MINI GAUGE
//////////////////////////////////////////////////////////////

class MiniGauge extends StatelessWidget {
  final String label;
  final Color color;

  const MiniGauge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 18,
          child: CustomPaint(
            painter: ArcPainter(
              startAngle: 3.14,
              sweepAngle: 2,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
//  BOTTOM ITEM
//////////////////////////////////////////////////////////////

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
                color: Colors.white,
                fontSize: 11,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
