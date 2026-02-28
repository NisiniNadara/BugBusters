import 'package:flutter/material.dart';
import 'app_lang.dart';
import 'settings_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color darkGreen = Color(0xFF1A5319);

  void _goBackToSettings(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackToSettings(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ===== Header =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _goBackToSettings(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            T.t("Back", "ආපසු"),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      T.t("Help & Support", "උදව් සහ සහාය"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      T.t("Get help for common issues", "සාමාන්‍ය ගැටළු සඳහා උදව් ලබාගන්න"),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _card(
                        title: T.t("Forgot password", "මුරපදය අමතකද?"),
                        body: T.t(
                          "Go to Change Password page and request OTP. Then enter OTP and set new password.",
                          "Change Password පිටුවට ගොස් OTP ඉල්ලන්න. OTP ඇතුළත් කර නව මුරපදය සකසන්න.",
                        ),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        title: T.t("Pump data not updating", "පම්ප් දත්ත යාවත්කාලීන නොවේ"),
                        body: T.t(
                          "Check internet connection and try again. Dashboard auto-refreshes every minute.",
                          "අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න. Dashboard මිනිත්තුවකට වරක් යාවත්කාලීන වේ.",
                        ),
                      ),
                      const SizedBox(height: 12),
                      _card(
                        title: T.t("Need more help?", "තවත් උදව් අවශ්‍යද?"),
                        body: T.t(
                          "Contact your technician or support team. (Add your contact number/email here if you have.)",
                          "ඔබගේ තාක්ෂණිකයා හෝ සහාය කණ්ඩායම අමතන්න. (ඔබට තිබේ නම් දුරකථන/ඊමේල් මෙහි දාන්න.)",
                        ),
                      ),
                      const SizedBox(height: 18),

                      // optional action buttons (UI still simple)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => _goBackToSettings(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            T.t("Back to Settings", "සැකසුම් වෙත ආපසු"),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}