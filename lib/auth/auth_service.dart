import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loggedInKey = 'is_logged_in';
  static const String _tokenKey = 'token';

  static Future<void> loginSuccess({required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_tokenKey, token);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_tokenKey);
  }
}