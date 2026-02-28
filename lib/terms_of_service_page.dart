import 'package:flutter/material.dart';
import 'app_lang.dart';
import 'settings_page.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
              // ===== Header (matches your style) =====
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
                      T.t("Terms of Service", "සේවා නියමයන්"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      T.t("Read and understand our terms", "අපගේ නියමයන් කියවා අවබෝධ කරගන්න"),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== Content Card =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
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
                        _sectionTitle(context, T.t("1) Acceptance", "1) එකඟතාවය")),
                        _sectionText(
                          context,
                          T.t(
                            "By using this app, you agree to follow these terms. If you do not agree, please stop using the app.",
                            "මෙම යෙදුම භාවිතා කිරීමෙන් ඔබ මෙම නියමයන්ට එකඟ වේ. එකඟ නොමැති නම් යෙදුම භාවිතා නොකරන්න.",
                          ),
                        ),
                        const SizedBox(height: 14),

                        _sectionTitle(context, T.t("2) Account & Security", "2) ගිණුම සහ ආරක්ෂාව")),
                        _sectionText(
                          context,
                          T.t(
                            "Keep your password safe. You are responsible for activities done using your account.",
                            "ඔබගේ මුරපදය ආරක්ෂිතව තබාගන්න. ඔබගේ ගිණුමෙන් සිදුවන ක්‍රියා සඳහා ඔබ වගකිව යුතුය.",
                          ),
                        ),
                        const SizedBox(height: 14),

                        _sectionTitle(context, T.t("3) Data & Privacy", "3) දත්ත සහ පෞද්ගලිකත්වය")),
                        _sectionText(
                          context,
                          T.t(
                            "We may store basic details needed to run the app (like user name, pump details). We do not sell your data.",
                            "යෙදුම ක්‍රියාත්මක කිරීමට අවශ්‍ය මූලික දත්ත (නම, පම්ප් විස්තර) ගබඩා විය හැක. ඔබගේ දත්ත විකිණීම අපි නොකරමු.",
                          ),
                        ),
                        const SizedBox(height: 14),

                        _sectionTitle(context, T.t("4) Changes", "4) වෙනස්කම්")),
                        _sectionText(
                          context,
                          T.t(
                            "We can update these terms. Please check this page sometimes for changes.",
                            "මෙම නියමයන් අපට යාවත්කාලීන කළ හැක. සමහරවිට මෙම පිටුව පරීක්ෂා කරන්න.",
                          ),
                        ),
                        const SizedBox(height: 14),

                        _sectionTitle(context, T.t("5) Contact", "5) සම්බන්ධ වීම")),
                        _sectionText(
                          context,
                          T.t(
                            "If you have questions, use the Help & Support page.",
                            "ප්‍රශ්න තිබේ නම් Help & Support පිටුව භාවිතා කරන්න.",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: darkGreen,
      ),
    );
  }

  Widget _sectionText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
      ),
    );
  }
}