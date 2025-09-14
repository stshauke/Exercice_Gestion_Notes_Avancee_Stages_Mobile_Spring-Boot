import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8080/api/v1/auth"; // ⚠️ Android Emulator
  final storage = const FlutterSecureStorage();

  Future<AuthResponse?> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Sauvegarder le token
      await storage.write(key: "jwt", value: authResponse.token);

      return authResponse;
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: "jwt");
  }

  Future<String?> getToken() async {
    return await storage.read(key: "jwt");
  }
}
