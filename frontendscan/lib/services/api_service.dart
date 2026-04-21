import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static const String baseUrlFlask = 'https://149d013cc93c.ngrok-free.app';
  static const String tokenKey = 'auth_token';
  static const Duration timeoutDuration = Duration(seconds: 60);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // -------------------- AUTH (Node.js) --------------------
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      )
          .timeout(timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _saveToken(data['token']);
        return data;
      } else {
        throw Exception(data['error'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Erreur réseau (signup): $e');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data['token']);
        return data;
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Erreur réseau (login): $e');
    }
  }

  static Future<void> logout() async {
    try {
      final headers = await _authHeaders;
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers);
    } catch (_) {
      // Ignorer erreurs
    } finally {
      await _removeToken();
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .get(Uri.parse('$baseUrl/auth/me'), headers: headers)
          .timeout(timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Erreur réseau (getProfile): $e');
    }
  }

  // -------------------- UPLOAD IMAGE (Node.js) --------------------
  static Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    String scanType = 'text',
  }) async {
    try {
      final headers = await _authHeaders;
      headers.remove('Content-Type'); // multipart boundary automatique

      final request =
      http.MultipartRequest('POST', Uri.parse('$baseUrl/scan/upload'));
      request.headers.addAll(headers);
      request.fields['scanType'] = scanType;
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Erreur réseau (uploadImage): $e');
    }
  }

  // -------------------- OCR (Flask) --------------------
  static Future<Map<String, dynamic>> sendImageForOCR(File imageFile) async {
    final uri = Uri.parse('$baseUrlFlask/ocr');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse =
    await request.send().timeout(timeoutDuration, onTimeout: () {
      throw Exception("OCR timeout");
    });

    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// OCR qui retourne seulement le nom du produit
  static Future<String?> ocrProduct(File imageFile) async {
    try {
      final result = await sendImageForOCR(imageFile);
      final product = result['product_name']?.toString().trim();
      if (product != null && product.isNotEmpty) {
        return product;
      }
      return "Inconnu"; // 🔹 retourne au moins une valeur
    } catch (e) {
      print("Erreur OCR: $e");
      return "Inconnu"; // 🔹 éviter le null
    }
  }

  // -------------------- ANALYSE PRODUIT (Flask) --------------------
  static Future<Map<String, dynamic>> analyzeProduct(String productName) async {
    final uri = Uri.parse('$baseUrlFlask/analyze');
    final response = await http
        .post(
      uri,
      headers: _headers,
      body: jsonEncode({'product_name': productName}),
    )
        .timeout(timeoutDuration);

    return _handleResponse(response);
  }

  // -------------------- HEALTH CHECK --------------------
  static Future<bool> checkHealth() async {
    try {
      final response =
      await http.get(Uri.parse('$baseUrl/health'), headers: _headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // -------------------- HELPER --------------------
  static Future<Map<String, dynamic>> _handleResponse(
      http.Response response, {
        int successCode = 200,
      }) async {
    final data = jsonDecode(response.body);
    if (response.statusCode == successCode) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Erreur inattendue');
    }
  }
}
