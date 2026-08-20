import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Talks to the SmartSpot backend (see /smartspot-backend). Handles auth
/// token storage and all authenticated requests.
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // TODO: point this at your deployed backend URL before release.
  // Use 10.0.2.2 instead of localhost when testing on the Android emulator.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> get _token => _storage.read(key: _tokenKey);

  Future<void> _saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<bool> get isLoggedIn async => (await _token) != null;

  Future<Map<String, String>> _authHeaders() async {
    final token = await _token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------- Auth ----------------

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) throw ApiException(data['error'] ?? 'Registration failed');
    await _saveToken(data['token'] as String);
    return data;
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) throw ApiException(data['error'] ?? 'Login failed');
    await _saveToken(data['token'] as String);
    return data;
  }

  Future<void> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(data['error'] ?? 'Request failed');
    }
  }

  Future<void> logout() => clearToken();

  // ---------------- Reminders ----------------

  Future<List<Map<String, dynamic>>> fetchReminders({DateTime? updatedSince}) async {
    final qp = updatedSince != null ? '?updatedSince=${Uri.encodeComponent(updatedSince.toIso8601String())}' : '';
    final res = await http.get(Uri.parse('$baseUrl/reminders$qp'), headers: await _authHeaders());
    _checkOk(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['reminders'] as List);
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl/reminders'), headers: await _authHeaders(), body: jsonEncode(body));
    _checkOk(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['reminder'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateReminder(String id, Map<String, dynamic> body) async {
    final res = await http.put(Uri.parse('$baseUrl/reminders/$id'), headers: await _authHeaders(), body: jsonEncode(body));
    _checkOk(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['reminder'] as Map<String, dynamic>;
  }

  Future<void> deleteReminderRemote(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/reminders/$id'), headers: await _authHeaders());
    if (res.statusCode != 204) _checkOk(res);
  }

  // ---------------- Favorites ----------------

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final res = await http.get(Uri.parse('$baseUrl/favorites'), headers: await _authHeaders());
    _checkOk(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['favorites'] as List);
  }

  Future<Map<String, dynamic>> createFavorite(Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl/favorites'), headers: await _authHeaders(), body: jsonEncode(body));
    _checkOk(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['favorite'] as Map<String, dynamic>;
  }

  Future<void> deleteFavoriteRemote(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/favorites/$id'), headers: await _authHeaders());
    if (res.statusCode != 204) _checkOk(res);
  }

  void _checkOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(data['error'] ?? 'Request failed (${res.statusCode})');
    } catch (_) {
      throw ApiException('Request failed (${res.statusCode})');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
