import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
  "http://192.168.109.136/flutter_application_2-main/api";

  // ---------- CORE POST ----------
  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse("$baseUrl/$endpoint");

    try {
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(body),
      );

      final raw = res.body.trim();
      if (raw.isEmpty) {
        return {"success": false, "alerts": [], "message": "Empty response"};
      }

      return jsonDecode(raw);
    } catch (e) {
      return {
        "success": false,
        "alerts": [],
        "message": "Network / JSON error: $e"
      };
    }
  }

  // FETCH ALERTS 
  static Future<Map<String, dynamic>> fetchAlerts({
    required dynamic userId,
  }) async {
    final int uid = int.tryParse(userId.toString()) ?? 0;
    return _post("fetch_alerts.php", {"user_id": uid});
  }

  //LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post("login.php", {
      "email": email,
      "password": password,
    });
  }

  // REGISTER 
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String telephone,
    required String role,
    required String password,
  }) async {
    return _post("register.php", {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "telephone": telephone,
      "role": role,
      "password": password,
    });
  }

  // ADD PUMP 
  static Future<Map<String, dynamic>> addPump({
    required String email,
    required String pumpName,
    required String location,
  }) async {
    return _post("add_pump.php", {
      "email": email,
      "pump_name": pumpName,
      "location": location,
    });
  }

  // CHANGE PASSWORD
  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String newPassword,
  }) async {
    return _post("change_password.php", {
      "email": email,
      "new_password": newPassword,
    });
  }
}
