import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';

class AddDevicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top spacing + title
            const SizedBox(height: 40),

            const Text(
              "Add Device",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A5319),
              ),
            ),

            const SizedBox(height: 20),

            
            const Spacer(),

            // Bottom green curved container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF1A5319),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    _inputField(
                      title: "Your Name",
                      hint: "Krish Kapoor",
                    ),
                    const SizedBox(height: 16),

                    _inputField(
                      title: "Device Name",
                      hint: "Pump 1",
                    ),
                    const SizedBox(height: 16),

                    _inputField(
                      title: "Device ID",
                      hint: "CP0125",
                    ),
                    const SizedBox(height: 30),

                    // ADD BUTTON → GO TO DASHBOARD
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input field widget
  Widget _inputField({required String title, required String hint}) {
    return Container(
      width: double.infinity, // controls width of input fields
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Text(
            hint,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
