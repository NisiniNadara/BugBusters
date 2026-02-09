import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2/flutter_application_2-main/api";

  static const String registerUrl = "$baseUrl/register.php";
  static const String loginUrl = "$baseUrl/login.php";
  static const String addDeviceUrl = "$baseUrl/add_device.php";
  static const String alertsUrl = "$baseUrl/get_alerts.php";

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(registerUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
  "first_name": firstName,
  "last_name": lastName,
  "email": email,
  "password": password,
}

    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(loginUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"email": email, "password": password},
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> addDevice({
    required String userId,
    required String deviceName,
    required String deviceCode,
  }) async {
    final res = await http.post(
      Uri.parse(addDeviceUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "user_id": userId,
        "device_name": deviceName,
        "device_code": deviceCode,
      },
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> fetchAlerts({
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse(alertsUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"user_id": userId},
    );
    return _parse(res);
  }

  static Map<String, dynamic> _parse(http.Response res) {
    if (res.statusCode != 200) {
      throw Exception("Server error ${res.statusCode}: ${res.body}");
    }
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Invalid JSON response: ${res.body}");
  }
}
