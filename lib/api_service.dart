import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // PHP path: C:\xampp\htdocs\flutter_application_2-main\api
  // URL (Android emulator): http://10.0.2.2/flutter_application_2-main/api
  static const String baseUrl =
      "http://10.0.2.2/flutter_application_2-main/api";

  static Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse("$baseUrl/$endpoint");

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }

    final raw = response.body.toString().trim();

    if (raw.isEmpty) {
      return {"success": false, "message": "Empty response from server"};
    }

    // Try JSON decode
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        "success": false,
        "message": "Server returned JSON but not an object",
        "raw": raw
      };
    } catch (e) {
      // Not JSON (HTML/404/PHP warning)
      final short = raw.length > 300 ? raw.substring(0, 300) : raw;
      return {
        "success": false,
        "message":
            "Server did not return JSON. HTTP ${response.statusCode}. $short",
        "raw": raw
      };
    }
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

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post("login.php", {
      "email": email,
      "password": password,
    });
  }

  // FETCH ALERTS (accepts String or int)
  static Future<Map<String, dynamic>> fetchAlerts({
    required dynamic userId,
  }) async {
    final intId = int.tryParse(userId.toString()) ?? 0;
    return _post("fetch_alerts.php", {"user_id": intId});
  }

  // ADD PUMP / DEVICE (table: pump, column: pump_name)
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

  // CHANGE PASSWORD (email + new_password)
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
