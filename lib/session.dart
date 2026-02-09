import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _keyUserId = "user_id";

  static Future<void> saveUserId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyUserId, id);
  }

  static Future<String?> getUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyUserId);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyUserId);
  }
}
