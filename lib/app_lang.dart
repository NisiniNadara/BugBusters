import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple app language controller (English / Sinhala).
/// Saves selection in SharedPreferences key: "app_lang"
class AppLangController extends ChangeNotifier {
  static final AppLangController instance = AppLangController._internal();
  AppLangController._internal();

  static const String _prefKey = "app_lang"; // "en" or "si"
  String _lang = "en";

  String get lang => _lang;
  bool get isSinhala => _lang == "si";

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _lang = sp.getString(_prefKey) ?? "en";
    notifyListeners();
  }

  Future<void> setLang(String newLang) async {
    if (newLang != "en" && newLang != "si") return;
    _lang = newLang;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_prefKey, _lang);
    notifyListeners();
  }
}

/// Translation helper.
/// Use: T.t("English", "සිංහල")
class T {
  static String t(String en, String si) {
    return AppLangController.instance.isSinhala ? si : en;
  }
}
